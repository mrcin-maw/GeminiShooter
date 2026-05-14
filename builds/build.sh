#!/bin/bash
# Build script for GeminiShooter - Atari 8-bit game in Mad Pascal

# Paths configuration (can be overridden with environment variables)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MP_PATH="${MP_PATH:-$SCRIPT_DIR/../MAD_Pascal/Mad-Pascal-1.7.3}"
MADS_PATH="${MADS_PATH:-$SCRIPT_DIR/../MAD_Pascal/Mad-Assembler-2.1.6}"
BUILDS_DIR="$SCRIPT_DIR/builds"

# Create builds directory if it doesn't exist
mkdir -p "$BUILDS_DIR"

# Check if compiler and assembler exist
if [ ! -f "$MP_PATH/src/mp" ]; then
    echo "Error: Mad Pascal compiler not found at $MP_PATH/src/mp"
    echo "Please compile the Mad Pascal compiler first:"
    echo "  cd $MP_PATH/src && fpc -Mdelphi -vh -O3 mp.pas"
    echo ""
    echo "Or set MP_PATH environment variable to the Mad Pascal directory."
    exit 1
fi

if [ ! -f "$MADS_PATH/mads" ]; then
    echo "Error: MADS assembler not found at $MADS_PATH/mads"
    echo "Please compile the MADS assembler first:"
    echo "  cd $MADS_PATH && fpc -Mdelphi -vh -O3 mads.pas"
    echo ""
    echo "Or set MADS_PATH environment variable to the MADS directory."
    exit 1
fi

echo "========================================"
echo "Building GeminiShooter for Atari 8-bit"
echo "========================================"

# Compile Pascal to Assembly
echo ""
echo "[1/2] Compiling Pascal to Assembly..."
"$MP_PATH/src/mp" "$SCRIPT_DIR/GeminiShooter.pas" \
    -ipath:"$MP_PATH/lib" \
    -ipath:"$MP_PATH/blibs" \
    -o "$BUILDS_DIR/GeminiShooter.a65"

if [ $? -ne 0 ]; then
    echo "Error: Pascal compilation failed!"
    exit 1
fi

# Assemble to XEX
echo ""
echo "[2/2] Assembling to XEX..."
"$MADS_PATH/mads" "$BUILDS_DIR/GeminiShooter.a65" \
    -x \
    -i:"$MP_PATH/base" \
    -o:"$BUILDS_DIR/GeminiShooter.xex"

if [ $? -ne 0 ]; then
    echo "Error: Assembly failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "Build successful!"
echo "Output: $BUILDS_DIR/GeminiShooter.xex"
echo "========================================"

# Show file size
ls -lh "$BUILDS_DIR/GeminiShooter.xex"
