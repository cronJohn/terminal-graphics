#!/bin/bash

install_deps_if_not_installed() {
    if ! command -v gif-for-cli > /dev/null; then
        echo "Installing dependencies..."

        git clone "https://github.com/google/gif-for-cli" .
        cd 'gif-for-cli'

        # Fix an issue with failing to import the 'third_party' module
        rm gif_for_cli/third_party
        cp third_party gif_for_cli/third_party  -r

        python3 setup.py install --user

        # Add to path
        if [ -d "$HOME/.local/bin" ] ; then
            PATH="$HOME/.local/bin:$PATH"
        fi

        # Check if installation worked
        if command -v gif-for-cli > /dev/null; then
            echo "Installation succeeded."
        else
            echo "Couldn't install gif-for-cli"
            sleep 2
            echo "Check the docs at https://github.com/google/gif-for-cli for more information."
            exit 1
        fi
    fi
}

draw_ascii(){
    eval "$(which gif-for-cli) "$1" "$options" "--cols $(tput cols)" "--rows $(tput lines)" 'party parrot' &"
}

run_cmd(){
    $cmd > /dev/null &
}

examples_dir='examples'

# main.sh options,cmd
user_input="$*"
IFS=',' read -r -a parts <<< "$user_input"

# check if the user didn't input options
if [ -z "${parts[1]}" ] ; then
    cmd="${parts[0]}"
else
    options="${parts[0]}"
    cmd="${parts[1]}"
fi

IFS=' '


# Main execution
install_deps_if_not_installed

run_cmd
CMD_ID=$!

draw_ascii
ASCII_ID=$!

while kill -0 "$CMD_ID" >/dev/null 2>&1; do
    :
done

kill $ASCII_ID # Stop animation when done

