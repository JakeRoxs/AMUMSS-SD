#!/usr/bin/env bash
# Run one downloaded builder mod in an isolated, writable test copy.
set -euo pipefail
root=$(readlink -f -- "$HOME/amumss-native-test")
archive="${1:?Mod archive path required}"
sandbox=$(mktemp -d "$root/investigation-XXXXXX")
rsync -a --exclude=REPORT.lua --exclude=MBINCompiler.log --exclude=ModScript/ --exclude=CreatedMODS/ --exclude=ModBackups/ \
    --exclude=TOOLS/ --exclude=MOD/ --exclude=_TEMP/ \
    "${AMUMSS_SOURCE:-$root/AMUMSS}/" "$sandbox/AMUMSS/"
mkdir -p "$sandbox/AMUMSS/ModScript"
ln -s "$root/venv" "$sandbox/venv"
printf 'Investigation workspace: %s\n' "$sandbox"
# The existing game, downloads, and original test workspace are read-only.
set +e
bwrap --ro-bind / / --bind "$sandbox" "$sandbox" --tmpfs /tmp \
    --dev /dev --proc /proc env AMUMSS_DIR="$sandbox/AMUMSS/MODBUILDER" \
    AMUMSS_LOG_ROOT="$sandbox/logs" LUA_RUNTIME="$root/native-runtime" \
    bash "$root/amumss-process.sh" "$archive"
status=$?
set -e
# Make isolated test history visible from the desktop launcher's history folder.
mkdir -p -- "$root/logs"
for run in "$sandbox"/logs/run-*; do
    [[ -d "$run" ]] || continue
    ln -s -- "$run" "$root/logs/$(basename "$run")"
done
exit "$status"
