#!/bin/bash

# Check if the input file is provided
if [ "$#" -gt 2 ]; then
    echo "Usage: $0 input_file.R render_format"
    exit 1
fi

input_file="$1"
render_format="$2"

# Check if the input file has a .R extension
if [[ "$input_file" != *.R ]]; then
    echo "Error: Input file must have a .R extension"
    exit 1
fi

# Check if the render format is accepted
if [[ -n "$render_format" && "$render_format" != html && "$render_format" != revealjs ]]; then
    echo "Error: Render format ${render_format} not accepted"
    exit 1
fi

# Check the file type
file_type=$(file "$input_file")

# If the file has CRLF line terminators, convert it
if [[ "$file_type" == *"CRLF"* ]]; then
  echo "File has CRLF line endings. Converting to Unix format (LF)..."

  # Backup the original file
  cp "$input_file" "$input_file.bak"

  # Convert CRLF to LF using sed
  sed -i 's/\r$//' "$input_file"

  echo "File is in DOS format and had to be converted to UNIX format. Original file backed up as ${input_file}.bak"
fi

# Derive the output file name by replacing .R with .qmd
output_file="${input_file%.R}.qmd"

# Create or clear the output file
> "$output_file"

# Extract title and author from file
author=$(cat "$input_file" | grep "\\# Author:" | head -n 1 | sed "s/# Author: //g")
title=$(cat "$input_file" | grep "\\# Title:" | head -n 1 | sed "s/# Title: //g")
date=$(cat "$input_file" | grep "\\# Date:" | head -n 1 | sed "s/# Date: //g")

# Read the input file line by line
while IFS= read -r line ; do
    # Check if the line matches the pattern #### X ####
    if [[ "$line" =~ ^####\ (.+)\ #### ]]; then
        # Extract the text X from the matched line
        chunk_name="${BASH_REMATCH[1]}"
        # Format the output as \`\`\` followed by a new line, then \`\`\`{r X}
        echo "\`\`\`" >> "$output_file"
        echo "### $chunk_name" >> "$output_file"
        echo "\`\`\`{r $chunk_name}" >> "$output_file"
    else
        # Write other lines directly to the output file
        echo "$line" >> "$output_file"
    fi
done < "$input_file"

# Remove the first occurrence of \`\`\` in the output file
sed -i '0,/^```$/ {/^```$/d;}' "$output_file"
#sed -i '0,/^```$/s/^```$//' "$output_file"

# Add \`\`\` at the end of the output file
echo "\`\`\`" >> "$output_file"

# Remove shebang line
sed -i '/^#!/d' "$output_file"

# Replace the metadata hashtags by '- ' so the output is listed
for element in Title Author Date Description ; do
        if grep -q "# ${element}:" "${output_file}" ; then sed -i 's/^# \(.*:\)/- \1/' "$output_file" ; fi
done
#sed -i 's/^# \(.*:\)/- \1/' "$output_file"

# Add header
# Define the content you want to add
HEADER_html="---
title: \"${title}\"
author: ${author}
date: ${date}
self-contained: true
format:
  html:
    page-layout: full
---"

HEADER_revealjs="---
title: \"${title}\"
author: ${author}
date: ${date}
self-contained: true
execute:
  echo: true
format:
  revealjs:
    smaller: true
    scrollable: true
---"

# Add headers to the beginning of the file
if [[ -n "${render_format}" && "${render_format}" == "html" ]]; then
    echo -e "${HEADER_html}\n\n$(cat "$output_file")" | sponge "$output_file"
fi

if [[ -n "${render_format}" && "${render_format}" == "revaljs" ]]; then
    echo -e "${HEADER_revealjs}\n\n$(cat "$output_file")" | sponge "$output_file"
fi
