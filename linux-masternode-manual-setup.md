# [:arrow_backward:](./README.md) Linux Masternode Manual Setup

## Table of contents
- **[Setup swap space](#setup-swap-space)**
- **[Update and upgrade](#update-and-upgrade)**
- **[Basic Intrusion Prevention with Fail2Ban](#basic-intrusion-prevention-with-fail2ban)**
- **[Set Up a Basic Firewall](#set-up-a-basic-firewall)**
- **[Install required dependencies](#install-required-dependencies)**
- **[Install the wallet](#install-the-wallet)**
- **[Configure the wallet](#configure-the-wallet)**
- **[Start the wallet](#start-the-wallet)**
- **[Getting masternode config for windows wallet](#getting-masternode-config-for-windows-wallet)**

## Setup swap space
This is our first step, i know **swap space** is slow, but for a **VPS** with only **1GB of ram** it's mandatory. Log into the **VPS** as root and start typing the following commands:

````bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
````

Now that the swap is created, let's make it work better

````bash
sudo nano /etc/sysctl.conf
````

Add to the bottom of the file

````
vm.swappiness=10
vm.vfs_cache_pressure=50	
````

Also let's make sure the swap if mounted again after a server restart

````bash
sudo nano /etc/fstab
````

Add to the bottom of the file

````
/swapfile   none    swap    sw    0   0
````

## Update and upgrade
Now let's run **update** and **upgrade** by typing the following commands:

````bash
sudo apt-get -y update
sudo apt-get -y upgrade
````

You will be asked to choose an option when upgrading, leave the default one that is selected and just hit **``Enter``**.

## Basic Intrusion Prevention with Fail2Ban
We will add a basic **dictionary attack** protection. This will ban an IP address for 10 minutes after 10 failed login attempts.

````bash
sudo apt-get -y install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
````

If you want to see what **Fail2Ban** is doing behing the scenes just type the following command. You can exit with **``CTRL+C``**.

````bash
sudo tail -f /var/log/fail2ban.log
````

## Set Up a Basic Firewall
**Ubuntu 16.04** can use the **UFW Firewall** to make sure only connections to certain services are allowed. We can set up a basic firewall very easily using this application.

````bash
sudo ufw allow OpenSSH
sudo ufw allow 5757/tcp
sudo ufw enable
````

You will be asked if you want to enable it, type **``Y``**. If you want to see the status of the **firewall** type the following command:

````bash
sudo ufw status
````

## Install required dependencies
In order to build the wallet, we need to install the following dependencies:

````bash
sudo apt-get install git nano wget curl software-properties-common
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install build-essential libtool autotools-dev pkg-config libssl-dev
sudo apt-get install libboost-all-dev
sudo apt-get install libevent-dev
sudo apt-get install libminiupnpc-dev
sudo apt-get install autoconf
sudo apt-get install automake
sudo apt-get install libdb4.8-dev libdb4.8++-dev
sudo apt-get install libzmq3-dev
````	

## Install the wallet
Now we need to get the binaries from **github** and install them globally. Type the following commands to do so:

````bash
cd
wget https://github.com/oryxian/oryxcoin-resources/releases/download/OryxCoin2.0.0/oryxcoin-v2-0-0-i686-linux-pc-gnu.tar.gz
tar -xzf oryxcoin-v2-0-0-i686-linux-pc-gnu.tar.gz
chmod 755 oryxcoind oryxcoin-cli oryxcoin-tx
strip oryxcoind oryxcoin-cli oryxcoin-tx
sudo mv oryxcoind oryxcoin-cli oryxcoin-tx /usr/bin
````

## Configure the wallet
Let's configure the wallet now, we'll start by **starting the wallet daemon for 10 seconds and then closing it again**. We are doing this so the wallet can dump it's core.

````bash
oryxcoin -daemon
# wait 5 seconds
oryxcoin-cli stop
````

Now lets configure the **``oryxcoin.conf``** configuration files. The file is located in **``~/.oryxcoin``** but we will use the following commands to add the required config.

````bash
mnip=$(curl --silent ipinfo.io/ip)

rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

rpcpass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcallowedip=127.0.0.1" > ~/.oryxcoin/oryxcoin.conf

oryxcoind -daemon

mnkey=$(oryxcoin-cli masternode genkey)

oryxcoin-cli stop

sleep 5

echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcallowedip=127.0.0.1\nmasternode=1\ndaemon=1\nbind=${mnip}:${COINPORT}\nmasternodeprivkey=${mnkey}"
````

## Start the wallet

````bash
orycoind -daemon
````

## Getting masternode config for windows wallet
:white_check_mark: **Great**, now everything is ready on our **Linux VPS**, type the following command to receive the line that you will need in order to finish the **Windows** part.

````bash
echo "masternode1 ${mnip}:5757 ${mnkey} <txid for 10000 ORYX> <output index for 10000 ORYX>"
````

**Save** this line somewhere on your pc and continue with the cold wallet part.
