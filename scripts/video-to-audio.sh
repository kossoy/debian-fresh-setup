#!/bin/bash

# Check if at least one argument (input file) is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <input_video.mp4> [output_audio.mp3]"
  exit 1
fi

# Assign arguments to variables
input_file="$1"
output_file="${2:-output_audio.mp3}"  # Default to output_audio.mp3 if not provided

# Use FFmpeg to extract audio from the video
ffmpeg -i "$input_file" -q:a 0 -map a "$output_file"

# Notify the user
echo "Audio has been successfully extracted as $output_file"