#!/bin/bash

# Script to extract various archive types in a specified directory.

# Check if a directory path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

TARGET_DIR="$1"

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' not found."
  exit 1
fi

echo "Searching for compressed files in '$TARGET_DIR'..."

# Find and process compressed files directly within the target directory (not recursively)
find "$TARGET_DIR" -maxdepth 1 -type f \( \
    -name "*.zip" -o \
    -name "*.tar.gz" -o -name "*.tgz" -o \
    -name "*.tar.bz2" -o -name "*.tbz2" -o \
    -name "*.tar.xz" -o -name "*.txz" -o \
    -name "*.rar" -o \
    -name "*.7z" \
\) -print0 | while IFS= read -r -d $'\0' file; do

    echo "Processing '$file'..."
    # Get the directory containing the file
    dir=$(dirname "$file")
    # Get the filename
    filename=$(basename "$file")

    # Change to the directory to extract files there
    # Use pushd/popd to manage directory changes safely
    pushd "$dir" > /dev/null

    extract_success=1 # Assume failure initially

    case "$filename" in
        *.zip)
            if command -v unzip &> /dev/null; then
                unzip -o "$filename" && extract_success=0
            else
                echo "Warning: 'unzip' command not found. Skipping '$filename'."
            fi
            ;;
        *.tar.gz|*.tgz)
            if command -v tar &> /dev/null; then
                tar -xzf "$filename" && extract_success=0
            else
                echo "Warning: 'tar' command not found. Skipping '$filename'."
            fi
            ;;
        *.tar.bz2|*.tbz2)
            if command -v tar &> /dev/null; then
                tar -xjf "$filename" && extract_success=0
            else
                echo "Warning: 'tar' command not found. Skipping '$filename'."
            fi
            ;;
        *.tar.xz|*.txz)
            if command -v tar &> /dev/null; then
                tar -xJf "$filename" && extract_success=0
            else
                echo "Warning: 'tar' command not found. Skipping '$filename'."
            fi
            ;;
        *.rar)
            if command -v unrar &> /dev/null; then
                unrar x -o+ "$filename" && extract_success=0 # -o+ overwrites existing files
            elif command -v unar &> /dev/null; then
                 unar -f "$filename" && extract_success=0 # -f force overwrite
            else
                echo "Warning: 'unrar' or 'unar' command not found. Skipping '$filename'."
            fi
            ;;
        *.7z)
            if command -v 7z &> /dev/null; then
                7z x -o. "$filename" -y && extract_success=0 # -o. extracts to current dir, -y assumes yes
            else
                echo "Warning: '7z' command not found. Skipping '$filename'."
            fi
            ;;
        *)
            echo "Warning: Unknown or unsupported archive type for '$filename'. Skipping."
            ;;
    esac

    # Return to the original directory
    popd > /dev/null

    if [ $extract_success -eq 0 ]; then
        echo "Successfully extracted '$filename'."
        # Optional: Uncomment the next line to remove the archive after successful extraction
        # rm "$file"
        # echo "Removed '$filename'."
    else
        echo "Error or skipping extraction for '$filename'."
    fi
    echo "----------------------------------------" # Separator
done

echo "Extraction process finished."
