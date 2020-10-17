#!/bin/sh

check_ssh_directory(){
    echo "Checking if ~/.ssh folder exists"
    if [ ! -d $HOME/.ssh/ ]; then
        echo "~/.ssh/ folder doesn't exist. Create .ssh or grant appropriate permissions \n\n"
        ls -la ~/.ssh/
        exit
    fi

    echo "Transfer private key to ~/.ssh folder \n\n"
    if [ ! -f ./cmubaymax.pem ]; then
        echo "Please place cmubaymax.pen file in this folder \n\n"
        exit
    else
        echo "Copying pem file to ~/.ssh folder \n\n"
        cp cmubaymax.pem $HOME/.ssh/cmubaymax.pem
        chmod 400 $HOME/.ssh/cmubaymax.pem
        echo "Copying identity file done! \n\n"
    fi
}

create_ssh_config(){
    echo "Create entry in ssh config \n\n"
    if [ ! -f $HOME/.ssh/config ]; then
        echo "Creating new file for config if it doesn't exist \n\n"
        touch $HOME/.ssh/config
        cat ./ssh_config | tee -a $HOME/.ssh/config
        echo "\n\nConfig file copied successfully \n\n"
    else
        echo "Config file exists, appending! \n\n"
        cat ./ssh_config | tee -a $HOME/.ssh/config
        echo "Config file copied successfully \n\n"
    fi
}

brew_install(){
if [[ $(command -v brew) == "" ]]; then
    echo "Brew not detected .. \n\n"
    echo "Installing Brew.... \n\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
}

autossh_install(){
echo "Install autossh to run ssh tunnel persistently \n\n"
if brew ls --versions autossh > /dev/null; then
    echo "Autossh already installed, skipping command to install... \n\n"
else
    brew install autossh
fi
}

autossh_config(){
echo "Creating port forwarding for Redshift database, so that it can be accessed locally \n\n"
autossh -M 0 -f -T -N cmubaymax

echo "Port forwarding enabled. The following commands can be used: \n"
echo "1. Enter the command 'ssh bastion' to connect to bastion server \n"  
echo "2. Enter the command 'psql -h localhost -p 5439 -U cmubaymax -W anki' to connect to the Redshift database \n"
}

# Checks if SSH directory is present and tries to transfer PEM key to it
check_ssh_directory

# Creates SSH config by copying ssh_config file in the directory to a file called config under ~/.ssh
create_ssh_config

# Installs brew if you haven't already done before
brew_install

# Installs autossh if not present
autossh_install

# Configures autossh with parameters in ssh_config file
autossh_config