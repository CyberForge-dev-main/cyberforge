#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-.}"
OUTPUT_FILE="$ROOT_DIR/project_dump.txt"

echo "=== CYBERFORGE PROJECT DUMP ===" > "$OUTPUT_FILE"
echo "Root: $ROOT_DIR" >> "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### DIRECTORY TREE" >> "$OUTPUT_FILE"
find "$ROOT_DIR" -type d \
  \( -name .git -o -name node_modules -o -name dist -o -name build -o -name archive -o -name backups \) \
  -prune -o -print >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### FILE CONTENTS" >> "$OUTPUT_FILE"

find "$ROOT_DIR" -type f \
  ! -path "*/.git/*" \
  ! -path "*/node_modules/*" \
  ! -path "*/dist/*" \
  ! -path "*/build/*" \
  ! -path "*/archive/*" \
  ! -path "*/backups/*" \
  ! -name "project_dump.txt" \
  ! -name "dump.sh" \
  ! -name "*.png" ! -name "*.jpg" ! -name "*.jpeg" ! -name "*.gif" ! -name "*.ico" ! -name "*.svg" ! -name "*.webp" \
  ! -name "*.pdf" ! -name "*.zip" ! -name "*.tar" ! -name "*.gz" ! -name "*.tgz" ! -name "*.bz2" ! -name "*.xz" ! -name "*.7z" ! -name "*.rar" \
  ! -name "*.mp3" ! -name "*.mp4" ! -name "*.avi" ! -name "*.mkv" ! -name "*.mov" ! -name "*.wav" ! -name "*.flac" \
  ! -name "*.woff" ! -name "*.woff2" ! -name "*.ttf" ! -name "*.otf" ! -name "*.eot" \
  ! -name "*.exe" ! -name "*.dll" ! -name "*.so" ! -name "*.dylib" ! -name "*.bin" ! -name "*.class" \
  ! -name "*.pyc" ! -name "*.pyo" \
  ! -name "package-lock.json" ! -name "yarn.lock" ! -name "pnpm-lock.yaml" | \
while read -r file; do
  MIME=$(file --mime-type -b "$file" 2>/dev/null || echo "unknown")
  case "$MIME" in
    text/*|application/json|application/javascript|application/xml|application/x-yaml|application/x-sh|application/x-python|inode/x-empty)
      echo "" >> "$OUTPUT_FILE"
      echo "FILE: $file" >> "$OUTPUT_FILE"
      echo "----------------------------------------" >> "$OUTPUT_FILE"
      cat "$file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      ;;
    *)
      ;;
  esac
done

echo "=== END ===" >> "$OUTPUT_FILE"
echo "Done: $OUTPUT_FILE"
