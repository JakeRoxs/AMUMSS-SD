#!/usr/bin/env bash
# Desktop Mode frontend for the experimental native processor.
set -euo pipefail

script_dir=$(dirname -- "$(readlink -f -- "$0")")
processor="$script_dir/amumss-process.sh"

if [[ ${1:-} == --run ]]; then
    shift
    log_dir="${AMUMSS_LOG_ROOT:-$HOME/amumss-native-test/logs}"
    mkdir -p -- "$log_dir"
    export AMUMSS_RUN_DIR
    AMUMSS_RUN_DIR=$(mktemp -d "$log_dir/run-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")
    mkdir -p -- "$AMUMSS_RUN_DIR/Logs"
    log="$AMUMSS_RUN_DIR/Logs/console.log"
    set +e
    /usr/bin/python3 "$script_dir/amumss-progress.py" "$processor" "$@" > "$AMUMSS_RUN_DIR/Logs/ui.log" 2>&1
    status=$?
    set -e
    if (( status != 0 )); then
        kdialog --title "AMUMSS: Build Failed" --error "The build did not complete (code $status).\nLogs: $AMUMSS_RUN_DIR/Logs\nNo output has been installed into the game."
        if kdialog --title "AMUMSS: Build Logs" --yesno "Open this run's logs to see what happened?"; then
            xdg-open "$AMUMSS_RUN_DIR/Logs"
        fi
        exit "$status"
    fi
    if kdialog --title "AMUMSS: Run Finished" --yesno "The processor finished. This does not verify the mod is correct: inspect the log for warnings and errors.\nLog: $log\nNo output has been installed into the game.\n\nOpen this run's output folder?"; then
        xdg-open "$AMUMSS_RUN_DIR/Output/"
    fi
    if kdialog --title "AMUMSS: Run History" --yesno "Open saved run logs and reports for review?"; then
        xdg-open "$log_dir"
    fi
    exit 0
fi

if [[ ! -f "$processor" ]]; then
    kdialog --error "Cannot find processor: $processor"
    exit 1
fi

if (( $# == 0 )); then
    if ! selection=$(kdialog --title "AMUMSS: Select Mod Archives" \
        --getopenfilename "$HOME/Downloads/" '*.zip *.7z *.rar|Mod archives' \
        --multiple --separate-output); then
        exit 0
    fi
    [[ -n "$selection" ]] || exit 0
    mapfile -t mods <<< "$selection"
else
    mods=("$@")
fi

if ! kdialog --title "AMUMSS: Experimental Build" --warningyesno \
    "Build ${#mods[@]} selected archive(s)?\n\nOnly select trusted mods: their Lua scripts execute code. Only scripts from these selections will be built, in a fresh workspace.\n\nOutput and logs stay in run history. Nothing will be installed into No Man's Sky. In-game behavior remains unverified."; then
    exit 0
fi

# Keep all paths as individual arguments, including filenames containing spaces.
exec /bin/bash "$0" --run "${mods[@]}"
