# Define the path to the .env directory
ENV_DIR="$HOME/.env"

# Check if the directory exists
if [ -d "$ENV_DIR" ]; then
    # Loop through each file in the .env directory
    for file in "$ENV_DIR"/*; do
        # Extract the filename to be used as the environment variable name
        var_name=$(basename "$file")

        # Read the contents of the file, join each line with ":" and store in a temp variable
        temp_var=$(paste -sd ":" "$file")

        # Check if the environment variable already exists
        if [ -z "${!var_name}" ]; then
            # If not, the variable gets the value of the temp variable
            export "$var_name=$temp_var"
        else
            # If it exists, append the temp variable to the existing value, separated by ":"
            export "$var_name=${!var_name}:$temp_var"
        fi
    done
fi
