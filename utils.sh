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

makeCerts(){
    if [ ! -d "$HOME/certs" ]; then
	cd $HOME
	mkdir certs
	echo "Certificat directory at $HOME/certs"
	cd certs

	echo "Configuring openssl"
	# https://github.com/jupyter/notebook/issues/507#issuecomment-145390380
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mycert.pem -out mycert.pem
	sudo chown $USER:$USER $HOME/certs/mycert.pem

	cd $HOME
    else
	ech "$HOME/certs exists already, not creating .pem file"
    fi
}
