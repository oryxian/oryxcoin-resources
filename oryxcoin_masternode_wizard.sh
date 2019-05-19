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
MAX=10

COINBINARIESLINK=https://github.com/oryxian/oryxcoin-resources/releases/download/v2.0.1/oryxcoin.2.0.1-linux-gnu-x64.tar.gz
COINBINARIESNAME=oryxcoin.2.0.1-linux-gnu-x64.tar.gz

COINPORT=5757
COINDAEMON=oryxcoind
COINCLI=oryxcoin-cli
COINTX=oryxcoin-tx
COINCORE=.oryxcoin
COINCONFIG=oryxcoin.conf

checkForUbuntuVersion() {
   echo "[1/${MAX}] Checking Ubuntu version..."
    if [[ `cat /etc/issue.net`  == *16.04* ]]; then
        echo -e "${GREEN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
    else
        echo -e "${RED}* You are not running Ubuntu 16.04.X. You are running `cat /etc/issue.net` ${NONE}";
        echo && echo "Installation cancelled" && echo;
        exit;
    fi
}

updateAndUpgrade() {
    echo
    echo "[2/${MAX}] Running update and upgrade. Please wait..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y > /dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /dev/null 2>&1
    echo -e "${GREEN}* Done${NONE}";
}

setupSwap() {
    echo -e "${BOLD}"
    read -e -p "Add 2 GB swap space? (Recommended for VPS that have 1GB of RAM or less) [Y/n] :" add_swap
    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        swap_size="2G"
    else
        echo && echo -e "${NONE}[3/${MAX}] Swap space not created."
        echo -e "${NONE}${GREEN}* Done${NONE}";
    fi

    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        echo && echo -e "${NONE}[3/${MAX}] Adding swap space...${YELLOW}"
        sudo fallocate -l $swap_size /swapfile
        sleep 2
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo -e "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null 2>&1
        sudo sysctl vm.swappiness=10
        sudo sysctl vm.vfs_cache_pressure=50
        echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "${NONE}${GREEN}* Done${NONE}";
    fi
}

installDependencies() {
    echo
    echo -e "[6/${MAX}] Installing dependencies. Please wait..."

    sudo apt-get install git nano wget curl software-properties-common -qq -y > /dev/null 2>&1
    sudo add-apt-repository ppa:bitcoin/bitcoin -y > /dev/null 2>&1
    sudo apt-get update -qq -y > /dev/null 2>&1
    sudo apt-get install build-essential libtool autotools-dev pkg-config libssl-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libboost-all-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libevent-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libminiupnpc-dev -qq -y > /dev/null 2>&1
    sudo apt-get install autoconf -qq -y > /dev/null 2>&1
    sudo apt-get install automake -qq -y > /dev/null 2>&1
    sudo apt-get install libdb4.8-dev libdb4.8++-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libzmq3-dev -qq -y > /dev/null 2>&1

    echo -e "${NONE}${GREEN}* Done${NONE}";
}

downloadWallet() {
    echo
    echo -e "[7/${MAX}] Compiling wallet. Please wait, this might take a while to complete..."
    cd && mkdir temp && cd temp

    wget $COINBINARIESLINK  > /dev/null 2>&1
    tar -xzf $COINBINARIESNAME  > /dev/null 2>&1
    chmod 755 $COINDAEMON
    chmod 755 $COINCLI
    chmod 755 $COINTX

    echo -e "${NONE}${GREEN}* Done${NONE}";
}

installWallet() {
    echo
    echo -e "[8/${MAX}] Installing wallet. Please wait..."
    strip $COINDAEMON
    strip $COINCLI
    strip $COINTX
    sudo mv $COINDAEMON /usr/bin
    sudo mv $COINCLI /usr/bin
    sudo mv $COINTX /usr/bin
    cd && sudo rm -rf temp
    cd
    echo -e "${NONE}${GREEN}* Done${NONE}";
}

configureWallet() {
    echo
    echo -e "[9/${MAX}] Configuring wallet. Please wait..."
    $COINDAEMON -daemon > /dev/null 2>&1
    sleep 30
    $COINCLI stop > /dev/null 2>&1
    sleep 30

    mnip=$(curl --silent ipinfo.io/ip)
    rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    rpcpass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

    echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcallowedip=127.0.0.1" > ~/$COINCORE/$COINCONFIG

    $COINDAEMON -daemon > /dev/null 2>&1
    sleep 30

    mnkey=$($COINCLI masternode genkey)

    $COINCLI stop > /dev/null 2>&1
    sleep 30

    echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcallowedip=127.0.0.1\nmasternode=1\ndaemon=1\nbind=${mnip}:${COINPORT}\nmasternodeprivkey=${mnkey}" > ~/$COINCORE/$COINCONFIG

    echo -e "${NONE}${GREEN}* Done${NONE}";
}

startWallet() {
    echo
    echo -e "[10/${MAX}] Starting wallet daemon..."
    $COINDAEMON -daemon > /dev/null 2>&1
    sleep 2
    echo -e "${GREEN}* Done${NONE}";
}

clear
cd

echo && echo

echo -e "${YELLOW}**********************************************************************${NONE}"
echo -e "${YELLOW}*                                                                    *${NONE}"
echo -e "${YELLOW}*    ${NONE}${BOLD}This script will install and configure your OryxCoin masternode.${NONE}${YELLOW}   *${NONE}"
echo -e "${YELLOW}*                                                                    *${NONE}"
echo -e "${YELLOW}**********************************************************************${NONE}"
echo && echo

echo -e "${BOLD}"
read -p "This script will setup your OryxCoin Masternode. Do you wish to continue? (y/n)?" response
echo -e "${NONE}"

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    checkForUbuntuVersion
    updateAndUpgrade
    setupSwap
    installDependencies
    downloadWallet
    installWallet
    configureWallet
    startWallet

    echo && echo -e "${BOLD}The VPS side of your masternode has been installed. Save the following line so you can use it to complete your local wallet part of the setup${NONE}".
    echo && echo -e "${BOLD}masternode1 ${mnip}:${COINPORT} ${mnkey} TX INDEX${NONE}"
    echo && echo -e "${BOLD}Monitor synchronization status until ‘\"blocks\": <current block num>’ is synchronized with explorer
${COINCLI} getinfo${NONE}" && echo
else
    echo && echo "Installation cancelled" && echo
fi
