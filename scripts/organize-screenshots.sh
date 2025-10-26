#!/bin/zsh

# Set your source directory
SRC_DIR="$HOME/Pictures/ScreenShots"

# Declare associative array (hash map)
typeset -A existing_files_map

echo "Loading existing files in target folders..."

# Step 1: Populate existing_files_map with filenames in all existing target folders
# Find all existing target directories (assuming they are only in the target structure)
# Use NULL_GLOB to avoid errors when no matches found
setopt NULL_GLOB
for dir in "$SRC_DIR"/*/*/*; do
  if [ -d "$dir" ]; then
    for file in "$dir"/*; do
      if [ -f "$file" ]; then
        filename=$(basename -- "$file")
        # Store filenames in the array, key = directory path
        existing_files_map["$dir"]+="$filename"$'\n'
      fi
    done
  fi
done

echo "Existing files loaded. Starting to process new files..."

# Step 2: Process each file
find "$SRC_DIR" -type f | while read -r file; do
  echo "Processing: $file"

  # Determine the target date folder based on modification time
  mod_epoch=$(stat -f "%m" "$file")
  date_str=$(date -r "$mod_epoch" +"%Y/%m/%d")
  target_dir="$SRC_DIR/$date_str"

  # Ensure target directory exists
  if mkdir -p "$target_dir"; then
    echo " - Ensured directory exists: $target_dir"
  fi

  filename=$(basename -- "$file")
  target_file="$target_dir/$filename"

  # Check if filename already exists in the target directory
  if print -rl -- "${existing_files_map[$target_dir]}" | grep -qx "$filename"; then
    echo "   ⚠️  '$filename' already exists in '$target_dir'. Skipping move to avoid overwrite."
    continue
  fi

  # Move the file if not already present
  # Check if the source file is already in the destination (avoid mv error)
  if [ "$file" = "$target_file" ]; then
    # echo "   ⚠️  Source and destination are the same file. Skipping move."
    continue
  fi

  if mv "$file" "$target_dir/"; then
    echo "   ✅ Moved successfully."
    # Add filename to the in-memory list for that directory
    existing_files_map["$target_dir"]+="$filename"$'\n'
  else
    echo "   ❌ Failed to move the file."
  fi
done

echo "Organization complete!"