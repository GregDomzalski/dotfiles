# Define the path to the .profile.d directory
PROFILE_D_DIR="$HOME/.profile.d"

# Check if the directory exists
if [ -d "$PROFILE_D_DIR" ]; then
    # Loop through each file in the .profile.d directory and source it
    for file in "$PROFILE_D_DIR"/*; do
        # Ensure the file is readable and is not a directory before sourcing
        if [ -f "$file" ] && [ -r "$file" ]; then
            source "$file"
        fi
    done
fi
