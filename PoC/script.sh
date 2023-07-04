#!/bin/bash

# Filter the files that are in the `old_language` folder
changed_old_files=$(echo "$changed_files" | grep "^ENGLISH/")

# Create the `new_language` folder if it doesn't exist
mkdir -p new_language

# Copy the changed files to the `new_language` folder
for file in $changed_old_files; do
  cp "$file" "new_language/$(basename "$file")"
done
