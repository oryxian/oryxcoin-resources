# Masternode Upgrade 21-07-2018

**IMPORTANT** This guide applies to people who created a masternode on a Linux VPS using the `oryxcoin_masternode_wizard.sh`. If you are installing this after 21-07-2018 9AM CET, the `oryxcoin_masternode_wizard.sh` will install the new wallet and upgrade is not necessary.

### Installation
Log into your VPS (using a sudo user or root) and run the following commands:

````
cd
wget https://raw.githubusercontent.com/oryxian/oryxcoin-resources/master/masternode-upgrade-210718.sh
bash masternode-upgrade-210718.sh
````

Just type `Y` to confirm the upgrade and wait a few minutes for the script to complete. Your masternode should continue working but you should keep an eye on it if it needs to be restarted.

### What if i didn't use the `oryxcoin_masternode_wizard.sh`

You will have to manually stop your masternode using `oryxcoin-cli stop` replace the `oryxcoind` `oryxcoin-cli` and `oryxcoin-tx` on your VPS and restart the wallet using `oryxcashd -daemon -reindex`.

**DO NOT DELETE in any circumstance the .oryxcash core folder. The folder can stay as it is.**
