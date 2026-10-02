#!/usr/bin/env bash
# AMUMSS Native Processor for Steam Deck / Linux
# Usage: amumss-process.sh <mod-file-or-directory> [more mods...]
#   - mod-file: .zip, .7z, or .rar file
#   - mod-directory: directory containing AMUMSS Lua scripts
#
# This script extracts the mod, finds the AMUMSS script, runs the processor,
# and retains only final output and logs in run history.
#
# Environment:
#   AMUMSS_DIR - path to AMUMSS/MODBUILDER directory (default: ~/amumss-native-test/AMUMSS/MODBUILDER)
#   NMS_PATH - path to No Man's Sky installation (default: /home/jake/.local/share/Steam/steamapps/common/No Mans Sky)

set -euo pipefail

# Configuration
AMUMSS_DIR="${AMUMSS_DIR:-$HOME/amumss-native-test/AMUMSS/MODBUILDER}"
NMS_PATH="${NMS_PATH:-/home/jake/.local/share/Steam/steamapps/common/No Mans Sky}"
LUA_RUNTIME="${LUA_RUNTIME:-$HOME/amumss-native-test/native-runtime}"
DOTNET_ROOT="${DOTNET_ROOT:-/var/home/linuxbrew/.linuxbrew/Cellar/dotnet/10.0.302/libexec}"
PYTHON_VENV="${PYTHON_VENV:-$HOME/amumss-native-test/venv}"

# Retain successful and failed runs without replacing earlier logs.
log_root="${AMUMSS_LOG_ROOT:-$HOME/amumss-native-test/logs}"
mkdir -p -- "$log_root"
run_dir="${AMUMSS_RUN_DIR:-$(mktemp -d "$log_root/run-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")}"
mkdir -p -- "$run_dir"
run_dir=$(readlink -f -- "$run_dir")
logs_dir="$run_dir/Logs"
if [[ -e "$logs_dir/run-info.txt" || -e "$run_dir/Output" ]]; then
    echo "Error: This run already contains retained data; choose a fresh run directory." >&2
    exit 1
fi
mkdir -p -- "$logs_dir"
work_dir=""
publish_dir=""
build_started=false
printf 'Started (UTC): %s\nBuilder: %s\n' "$(date -u +%FT%TZ)" "$AMUMSS_DIR" > "$logs_dir/run-info.txt"
printf 'Input: %q\n' "$@" >> "$logs_dir/run-info.txt"
exec 3>&1 4>&2
exec > >(tee "$logs_dir/console.log" >&3) 2>&1
log_pid=$!
finish_run() {
    local status=$?
    set +e
    trap - EXIT
    # Do not attribute stale reports from an earlier build to this run.
    local report archive_failed=0
    if $build_started; then
        for report in "$AMUMSS_DIR/../REPORT.lua" "$AMUMSS_DIR/REPORT.lua" "$AMUMSS_DIR/MBINCompiler.log" "$AMUMSS_DIR/../MBINCompiler.log" "$AMUMSS_DIR/FailedScriptList.txt"; do
            if [[ -f "$report" && "$report" -nt "$logs_dir/run-info.txt" ]]; then
                cp -- "$report" "$logs_dir/$(basename "$(readlink -f -- "$(dirname "$report")")")-$(basename "$report")" || archive_failed=1
            fi
        done
    fi
    cd "$run_dir"
    if [[ -n "$publish_dir" ]]; then rm -rf -- "$publish_dir"; fi
    if (( archive_failed )); then
        echo "Error: Could not retain diagnostics; temporary build preserved at $work_dir"
        if (( status == 0 )); then status=1; fi
    elif [[ -n "$work_dir" ]]; then
        if ! rm -rf -- "$work_dir"; then
            echo "Error: Could not remove temporary build at $work_dir"
            if (( status == 0 )); then status=1; fi
        fi
    fi
    printf '\nWrapper exit status: %s (not a mod correctness check)\n' "$status"
    printf 'Finished (UTC): %s\nExit status: %s\n' "$(date -u +%FT%TZ)" "$status" >> "$logs_dir/run-info.txt"
    exec 1>&3 2>&4
    wait "$log_pid" || true
    printf 'Run history: %s\n' "$run_dir"
    exit "$status"
}
trap finish_run EXIT
echo "Run history: $run_dir"

# Validate directories
if [ ! -d "$AMUMSS_DIR" ]; then
    echo "Error: AMUMSS_DIR not found: $AMUMSS_DIR"
    echo "Set AMUMSS_DIR to your AMUMSS/MODBUILDER directory."
    exit 1
fi

if [ ! -d "$LUA_RUNTIME" ]; then
    echo "Error: LUA_RUNTIME not found: $LUA_RUNTIME"
    exit 1
fi

# Read NMS path from config file
NMS_CONFIG="$AMUMSS_DIR/../CONFIG/NMS_FOLDER.txt"
if [ -f "$NMS_CONFIG" ]; then
    NMS_PATH=$(cat "$NMS_CONFIG" | tr -d '\n\r')
fi

if [ ! -d "$NMS_PATH" ]; then
    echo "Error: NMS_PATH not found: $NMS_PATH"
    echo "Check $NMS_CONFIG"
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 <mod-file-or-directory> [more mods...]"
    echo "  mod-file: .zip, .7z, or .rar file"
    echo "  mod-directory: directory containing AMUMSS Lua scripts"
    exit 1
fi

# Validate and stage every selection before starting any build.
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/amumss-build-XXXXXXXX")
work_dir=$(readlink -f -- "$work_dir")
mkdir -p -- "$work_dir/inputs" "$work_dir/selected-scripts"
input_number=0
script_count=0
for mod in "$@"; do
    input_number=$((input_number + 1))
    mod=$(readlink -f -- "$mod")
    if [ -f "$mod" ]; then
        echo "Processing: $mod"
        ext="${mod##*.}"
        temp_dir="$work_dir/inputs/$input_number"
        mkdir -p -- "$temp_dir"

        case "${ext,,}" in
            zip)
                unzip -q "$mod" -d "$temp_dir"
                ;;
            7z)
                7z x -o"$temp_dir" "$mod" > /dev/null
                ;;
            rar)
                7z x -o"$temp_dir" "$mod" > /dev/null
                ;;
            lua)
                cp -- "$mod" "$temp_dir/"
                ;;
            *)
                echo "Error: Unknown file type: $mod"
                exit 1
                ;;
        esac

    elif [ -d "$mod" ]; then
        echo "Processing: $mod"
        temp_dir="$mod"
    else
        echo "Error: $mod not found"
        exit 1
    fi
    find "$temp_dir" -type d -name ModHelperScripts -prune -o -type f -iname '*.lua' -print0 > "$work_dir/input-scripts.list"
    mapfile -d '' -t scripts < "$work_dir/input-scripts.list"
    if (( ${#scripts[@]} == 0 )); then
        echo "Error: No AMUMSS Lua script found in $mod; build cancelled."
        exit 1
    fi
    for script_file in "${scripts[@]}"; do
        name=$(basename -- "$script_file")
        name="${name%.*}.lua"
        if [[ -e "$work_dir/selected-scripts/$name" ]]; then
            echo "Error: Duplicate script filename '$name'; build cancelled to avoid overwriting a selection."
            exit 1
        fi
        echo "Found script: $name"
        cp -- "$script_file" "$work_dir/selected-scripts/$name"
        printf 'Archive/input: %q -> Script: %q\n' "$mod" "$name" >> "$logs_dir/run-info.txt"
        script_count=$((script_count + 1))
    done
    # AMUMSS explicitly treats this reserved directory as auxiliary code, not mods.
    find "$temp_dir" -type d -name ModHelperScripts -prune -print0 > "$work_dir/input-helpers.list"
    mapfile -d '' -t helper_dirs < "$work_dir/input-helpers.list"
    for helper_dir in "${helper_dirs[@]}"; do
        find "$helper_dir" -type f -print0 > "$work_dir/input-helper-files.list"
        mapfile -d '' -t helper_files < "$work_dir/input-helper-files.list"
        for helper_file in "${helper_files[@]}"; do
            relative="${helper_file#"$helper_dir/"}"
            staged_helper="$work_dir/selected-helpers/$relative"
            if [[ -f "$staged_helper" ]] && ! cmp -s -- "$helper_file" "$staged_helper"; then
                echo "Error: Conflicting helper '$relative'; build cancelled."
                exit 1
            fi
            mkdir -p -- "$(dirname -- "$staged_helper")"
            cp -- "$helper_file" "$staged_helper"
        done
    done
done

# Copy application/dependencies, never the old ModScript or build artifacts.
source_root=$(readlink -f -- "$AMUMSS_DIR/..")
mkdir -p -- "$work_dir/workspace/AMUMSS"
rsync -a --exclude=ModScript/ --exclude=CreatedMODS/ --exclude=ModBackups/ \
    --exclude=TOOLS/ --exclude=MOD/ --exclude=_TEMP/ --exclude=REPORT.lua \
    --exclude=MBINCompiler.log --exclude=FailedScriptList.txt \
    "$source_root/" "$work_dir/workspace/AMUMSS/"
AMUMSS_DIR="$work_dir/workspace/AMUMSS/MODBUILDER"
mkdir -p -- "$AMUMSS_DIR/../ModScript" "$AMUMSS_DIR/../TOOLS/SavedSections"
cp -- "$work_dir/selected-scripts/"*.lua "$AMUMSS_DIR/../ModScript/"
if [[ -d "$source_root/ModScript/ModHelperScripts" || -d "$work_dir/selected-helpers" ]]; then
    mkdir -p -- "$AMUMSS_DIR/../ModScript/ModHelperScripts"
    if [[ -d "$source_root/ModScript/ModHelperScripts" ]]; then
        rsync -a "$source_root/ModScript/ModHelperScripts/" "$AMUMSS_DIR/../ModScript/ModHelperScripts/"
    fi
    if [[ -d "$work_dir/selected-helpers" ]]; then
        rsync -a "$work_dir/selected-helpers/" "$AMUMSS_DIR/../ModScript/ModHelperScripts/"
    fi
fi
if [[ -d "$PYTHON_VENV" ]]; then
    ln -s -- "$(readlink -f -- "$PYTHON_VENV")" "$work_dir/workspace/venv"
fi
printf 'Execution builder: %s\nSelected scripts: %s\n' "$AMUMSS_DIR" "$script_count" >> "$logs_dir/run-info.txt"

echo ""
echo "=== Running AMUMSS Processor ==="
echo ""

: > "$AMUMSS_DIR/../REPORT.lua"
: > "$AMUMSS_DIR/FailedScriptList.txt"

# Set up environment
export DOTNET_ROOT="$DOTNET_ROOT"
export _DEV_MODE="${_DEV_MODE:-D}"
export AMUMSS_EXPECTED_SCRIPTS="$script_count"
export PATH="$DOTNET_ROOT/libexec:$PATH"
export LUA_PATH="$LUA_RUNTIME/lua/?.lua;;"
export LUA_CPATH="$LUA_RUNTIME/modules/?.so;;"

# Run the processor
cd "$AMUMSS_DIR"
find ../ModScript -type f -name '*.lua' -exec sha256sum -- {} + > "$logs_dir/scripts.sha256"
processor_status=0
build_started=true
timeout 300 "$LUA_RUNTIME/bin/lua" LoadAndExecuteModScript.lua || processor_status=$?
if [[ -s "$AMUMSS_DIR/FailedScriptList.txt" ]]; then
    echo "Error: One or more selected scripts failed; see FailedScriptList.txt in run history."
    if (( processor_status == 0 )); then processor_status=2; fi
fi
if (( processor_status != 0 )); then
    echo "Error: Processor exited with status $processor_status; run incomplete."
    exit "$processor_status"
fi

# Publish only completed output, atomically within the retained run directory.
if [[ ! -d "$AMUMSS_DIR/../CreatedMODS" ]] || [[ -z "$(find "$AMUMSS_DIR/../CreatedMODS" -type f -print -quit)" ]]; then
    echo "Error: Processor produced no final files; run incomplete."
    exit 2
fi
echo "Saving final files to $run_dir/Output"
publish_dir=$(mktemp -d "$run_dir/.output-XXXXXXXX")
rsync -a "$AMUMSS_DIR/../CreatedMODS/" "$publish_dir/"
mv -T -- "$publish_dir" "$run_dir/Output"
publish_dir=""

echo ""
echo "=== Done ==="
echo "MOD files created in: $run_dir/Output/"
