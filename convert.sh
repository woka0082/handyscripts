#!/bin/sh
# convert all photos in the current dir to 1920x1080! and move the old ones to "old" dir

mkdir -p old && for img in *.{jpg,JPG,jpeg,JPEG,png,PNG}; do 
  [ -f "$img" ] || continue
  magick "$img" -resize 1920x1080! "resized_$img" && mv "$img" old/ && mv "resized_$img" "$img"
done
