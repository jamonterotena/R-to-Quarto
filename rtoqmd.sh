#!/bin/bash

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_file.R"
    exit 1
fi

input_file="$1"

# Check if the input file has a .R extension
if [[ "$input_file" != *.R ]]; then
    echo "Error: Input file must have a .R extension"
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

# Read the input file line by line
while IFS= read -r line ; do
    # Check if the line matches the pattern #### X ####
    if [[ "$line" =~ ^####\ (.+)\ #### ]]; then
        # Extract the text X from the matched line
        chunk_name="${BASH_REMATCH[1]}"
        # Format the output as \`\`\` followed by a new line, then \`\`\`{r X}
        echo "\`\`\`" >> "$output_file"
	echo "# $chunk_name" >> "$output_file"
        echo "\`\`\`{r $chunk_name}" >> "$output_file"
    else
        # Write other lines directly to the output file
        echo "$line" >> "$output_file"
    fi
done < "$input_file"

# Remove the first occurrence of \`\`\` in the output file
sed -i '0,/\`\`\`/d' "$output_file"

# Add \`\`\` at the end of the output file
echo "\`\`\`" >> "$output_file"

#echo "Conversion complete! Output written to $output_file."
#head -n 20 "$output_file"
