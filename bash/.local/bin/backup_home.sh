#!/bin/bash

# Backup home directory to /tmp/

user=$(whoami)
current_date=$(date +%Y-%m-%d_%H-%M-%S)
input=/home/$user
output_dir=/home/$user/backups
output=/${output_dir}/${user}_home_${current_date}.tar.gz

echo "Starting backup. This will take a while..."

# Check if pigz is installed
if ! command -v pigz &> /dev/null; then
	echo "Error: pigz is not installed. :("
    exit 1
fi

mkdir -p $output_dir

tar -I pigz -cf $output \
	--exclude="$output_dir" \
	--exclude=".cache" \
	--exclude="Downloads" \
	--exclude=".config/chromium" \
	--exclude=".zen" \
	--exclude=".local/lib/node_modules/" \
	$input

if [ $? -eq 0 ]; then
	echo "Backed up $input to $output. :D"
else
	echo "Backup failed :("
	exit 1
fi
