#!/usr/bin/env bash
# AMUMSS Native Processor Runner for Linux
# Runs the AMUMSS mod processor using the native Lua runtime.
# Replaces the Windows bzrunM.bat orchestration layer.

set -euo pipefail

AMUMSS_ROOT="${AMUMSS_ROOT:-/tmp/kilo/AMUMSS}"
MODBUILDER="$AMUMSS_ROOT/MODBUILDER"
RUNTIME="${AMUMSS_RUNTIME:-/tmp/kilo/native-runtime}"
LUA="$RUNTIME/bin/lua"

if [ ! -d "$MODBUILDER" ]; then
    echo "Error: MODBUILDER directory not found at $MODBUILDER" >&2
    exit 1
fi

if [ ! -x "$LUA" ]; then
    echo "Error: Native runtime not found at $RUNTIME" >&2
    echo "Run: python scripts/setup_native_runtime.py $RUNTIME" >&2
    exit 1
fi

export LUA_PATH="$RUNTIME/lua/?.lua;;"
export LUA_CPATH="$RUNTIME/modules/?.so;;"

cd "$MODBUILDER"

echo "AMUMSS Native Processor Runner"
echo "============================="
echo "Root:    $AMUMSS_ROOT"
echo "Runtime: $RUNTIME"

# Check for NMS_FOLDER.txt
if [ ! -f "../CONFIG/NMS_FOLDER.txt" ]; then
    echo "Error: CONFIG/NMS_FOLDER.txt not found" >&2
    echo "Create it with your No Man's Sky installation path" >&2
    exit 1
fi

NMS_FOLDER="$(cat "../CONFIG/NMS_FOLDER.txt" | tr -d '\n\r')"
echo "NMS:     $NMS_FOLDER"

# Check for mod scripts
SCRIPT_COUNT=$(find "../MODSCRIPT" -name "*.lua" -type f 2>/dev/null | wc -l)
echo "Scripts: $SCRIPT_COUNT"
echo ""

if [ "$SCRIPT_COUNT" -eq 0 ]; then
    echo "No mod scripts found in MODSCRIPT/" >&2
    exit 1
fi

# Run the main processor
echo "Running processor..."
echo ""

"$LUA" LoadAndExecuteModScript.lua "$@" 2>&1

EXIT_CODE=$?
echo ""
echo "Processor exited with code: $EXIT_CODE"

if [ -f "exitCode.txt" ]; then
    EXIT_CODE_FILE=$(cat "exitCode.txt" | tr -d '\n\r')
    echo "exitCode.txt: $EXIT_CODE_FILE"
    rm -f "exitCode.txt"
fi

exit $EXIT_CODE
