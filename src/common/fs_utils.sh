#!/bin/bash -eu

force_dir_link() {
  local override_path=$1 # location that will be overridden or replaced (the destination where the symbolic link will be created)
  local target_path=$2 # target that the symbolic link will point to (the actual source directory or file).

  # Check if the override path is already a symbolic link to the target path
  if [ -L "$override_path" ] && [ "$(readlink "$override_path")" == "$target_path" ]; then
    echo "The override path $override_path is already a symbolic link to $target_path. No changes made."
    return 0
  fi

  # Remove the override path if it exists (directory, file, or symbolic link)
  if [ -e "$override_path" ]; then
    echo "Removing existing override path $override_path..."
    rm -rf "$override_path"
  fi

  # Create a symbolic link pointing to the target path
  echo "Creating symbolic link from $override_path to $target_path..."
  ln -s "$target_path" "$override_path"
}

force_file_link() {
  local override_path=$1
  local target_file=$2

  # Check if the override path is a symbolic link
  if [ -L "$override_path" ]; then
    echo "The override path $override_path is already a symbolic link. No changes made."
    return 0
  fi

  # Remove the override path if it exists (file or something else)
  if [ -e "$override_path" ]; then
    echo "Removing existing override path $override_path..."
    rm -f "$override_path"
  fi

  # Create a symbolic link pointing to the target file
  echo "Creating symbolic link from $override_path to $target_file..."
  ln -s "$target_file" "$override_path"
}
