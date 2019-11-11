#!/bin/bash

appendFile(){
    echo "$1" | sudo tee -a "$2" > /dev/null
}

appendBashrc(){
    FILE="$HOME/.bashrc"

    # Check is string exists in ~/.bashrc
    if ! grep -q "$1" $FILE; then
	appendFile "$1" "$FILE"
	source ~/.bashrc
    else
	echo "$1 exists in $FILE"
    fi
}
