#!/usr/bin/env bash

# Backup home directory to /tmp/

user=$(whoami)
current_date=$(date +%Y-%m-%d_%H-%M-%S)
input=/home/$user
output_dir=/home/$user/backups
output=/${output_dir}/${user}_home_${current_date}.tar.gz
function total_files {
        find $1 -type f | wc -l
}
function total_directories {
        find $1 -type d | wc -l
}
available_space=$(df "$output_dir" | awk 'NR==2 {print $4}')
# Warn if less than 10GB (10485760 KB) free
if [ "$available_space" -lt 10485760 ]; then
    echo "WARNING: Low disk space. Proceed with caution."
fi

echo "Starting backup. This will take a while..."

echo -n "Files to be included:"
total_files $input
echo -n "Directories to be included:"
total_directories $input

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
	--exclude=".local/share/Steam" \
	--exclude=".npm" \
	--exclude="node_modules" \
	--exclude="target" \
	--exclude=".cargo/registry" \
	--exclude=".var/app" \
	$input

if [ $? -eq 0 ]; then
	echo "Backed up $input to $output. :D"
else
	echo "Backup failed :("
	exit 1
fi
