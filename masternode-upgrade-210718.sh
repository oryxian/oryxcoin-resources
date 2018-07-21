#!/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

COINBINARIESLINK=https://github.com/oryxian/oryxcoin-resources/releases/download/1.0.1/oryxcoin-linux-cli-1-0-1.tar.gz
COINBINARIESNAME=oryxcoin-linux-cli-1-0-1.tar.gz
COINDAEMON=oryxcoind
COINCLI=oryxcoin-cli
COINTX=oryxcoin-tx

downloadNewWallet() {
	echo -e "${BOLD}[1/3]${NONE} Downloading new wallet"

	cd && mkdir newOryxWallet && cd newOryxWallet

    wget $COINBINARIESLINK  > /dev/null 2>&1
    tar -xzf $COINBINARIESNAME  > /dev/null 2>&1
    chmod 755 $COINDAEMON
    chmod 755 $COINCLI
    chmod 755 $COINTX
    strip $COINDAEMON
    strip $COINCLI
    strip $COINTX

	echo && echo -e "${GREEN}* Done${NONE}"
}

removeOldWallet() {
	echo && echo -e "${BOLD}[2/3]${NONE} Removing old wallet"

	$COINCLI stop > /dev/null 2>&1
	sleep 10

	cd /usr/bin
	sudo rm -rf $COINDAEMON
    sudo rm -rf $COINCLI
    sudo rm -rf $COINTX

	echo && echo -e "${GREEN}* Done${NONE}"
}

installNewWallet() {
	echo && echo -e "${BOLD}[3/3]${NONE} Installing new wallet"

	cd && cd newOryxWallet
	sudo mv $COINDAEMON /usr/bin
    sudo mv $COINCLI /usr/bin
    sudo mv $COINTX /usr/bin

    sleep 5
    $COINDAEMON -daemon > /dev/null 2>&1
    sleep 5

    cd && sudo rm -rf newOryxWallet

	echo && echo -e "${GREEN}* Done${NONE}"
}

clear
echo && echo -e "${BOLD}This script will upgrade your OryxCoin Masternodes."
echo && echo -e "${RED}THIS WILL ONLY WORK IF YOU INSTALLED MASTERNODE USING THE ORYXCOIN MASTERNODE WIZARD SCRIPT.${NONE}${BOLD}"
echo && echo -e "If you didn't you will need to manually stop the oryxcash daemon using oryxcoin-cli stop, delete oryxcoind oryxcoin-cli oryxcoin-tx and download the new ones from the same link and start oryxcoind -daemon after that."
echo && echo -e "${RED}DO NOT DELETE THE .oryxcoin CORE FOLDER${NONE}${BOLD}"
echo

read -p "Do you wish to continue? (y/n)? " response
echo -e "${NONE}"

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
	downloadNewWallet
	removeOldWallet
	installNewWallet

	echo && echo -e "${GREEN}SUCCESS!${NONE} ${BOLD} Masternode upgrade finished.${NONE}" && echo
else
echo && echo "Installation cancelled" && echo
fi
