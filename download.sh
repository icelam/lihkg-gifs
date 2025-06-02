#!/bin/bash
# This script downloads APNG sticker preview from LIHKG and convert it to GIF.
# Install imagemagick 7.1.1-47 and exiftool 13.25 dependencies via Homebrew before running this script.

# Pre-check TXT file format as while IFS= read -r url; do #... done needs trailing new line to work properly
for input_file in data/*.txt; do
  # If last character in TXT file is empty, then file is valid
  if [[ -s "$input_file" && -z "$(tail -c 1 "$input_file")" ]]; then
    echo "✅ Precheck: $input_file has correct format."
  else
    echo "⛔️ Precheck: Missing trailing new line for $input_file."
    exit 1
  fi
done

download_directory="download"
output_directory="$download_directory/output"
converted_directory="$download_directory/converted"

# Clean up old downloads
rm -rfi "$download_directory"

# Create the output directory if it doesn't exist
mkdir -p "$converted_directory"
mkdir -p "$output_directory"

for input_file in data/*.txt; do
  # Check if there are any PNG files
  if [[ ! -e "$input_file" ]]; then
    echo "No TXT files found in the directory."
    break
  fi
  
  sub_output_directory="${input_file%.txt}"
  sub_output_directory="${sub_output_directory//data\//}"
  full_output_directory="$output_directory/$sub_output_directory"
  full_converted_directory="$converted_directory/$sub_output_directory"

  # Create sub output directory if it doesn't exist
  mkdir -p "$full_output_directory"
  mkdir -p "$full_converted_directory"

  counter=1

  # Read each line from the input file
  while IFS= read -r url; do
    # Generate a zero-padded filename
    padded_number=$(printf "%02d" "$counter")
    file_name="${padded_number}_$(basename "$url")"
    output_file_path="$full_output_directory/$file_name"
    converted_file_path="$full_converted_directory/${sub_output_directory}_${file_name%.png}.gif"

    # Download the file
    if curl -sS -o "$output_file_path" "$url"; then
      echo "Downloaded: $sub_output_directory/$file_name"
      
      magick APNG:"$output_file_path" -coalesce -layers OptimizeTransparency -dither None "$converted_file_path"
      
      if [[ $? -eq 0 ]]; then
        echo "Converted $sub_output_directory/$file_name to $converted_file_path successfully."
        
        # Detect if image has only 1 frame and perform necessary patching
        # Since SDWebImageSwiftUI render GIFs with single frame and delay = 0 as transparent
        frame_count=$(exiftool -b -FrameCount $converted_file_path)
        
        if [[ -z "$frame_count" ]]; then
          echo "Patching $converted_file_path to add 1 more frame..."
          magick "$converted_file_path" -coalesce -duplicate 1 -set delay 20 "$converted_file_path"
          frame_count=$(exiftool -b -FrameCount $converted_file_path)
        fi

        echo "Frame Count: $frame_count"
      else
        echo "Failed to convert $output_file_path."
      fi
    else
      echo "Failed to download: $url"
    fi

    # Increment the counter
    ((counter++))
  done < "$input_file"
done