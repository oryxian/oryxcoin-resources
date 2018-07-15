# Oryxcoin Masternode Cold Windows - Hot Linux Wallet Install Guide

## Requirements

- 10,000 ORYX coins
- VPS Server with root access runing Ubuntu 16.04 x64 operation with the following minimum specs:
	- 1GHZ CPU Core
	- 1GB of ram
- Windows computer with a ssh client installed ( www.putty.org is recommended )

## Setting up the collateral address
We are going to start with the **collateral address** setup so we can get all the confirmations needed to start the masternode, till we finish the rest of the setup.

**Step 1 - Create new receiving address** 

Go to **``File > Receiving Addresses``** menu on the top-left and click on **``New Address``** button. In here give it a name, we will call it ``masternode1`` and click the **``Ok``** button.

**Step 2 - Send 10,000 OryxCoin Coins** 

Go to the **``Send``** tab and copy paste the address created earlier in the **``Pay to``** input ( the label will be automatically set to the name you gave it in **Step 1**), type in the **``Amount``** input exactly ``10000.00000000``. 
Now double check all the inputs and click on the **``Send``** button in order to send the **10,000** coins to your masternodes collateral address.

## Setting up the VPS
Log intro your **VPS** using **[www.putty.org](http://www.putty.org)** or any other **ssh client** you have as **root** and type the following commands:

````
cd
wget "https://raw.githubusercontent.com/oryxian/oryxcoin-resources/master/oryxcoin_masternode_wizard.sh"
bash oryxcoin_masternode_wizard.sh
````

After the script finished it will output a line that you will need to save in order to finish the setup.

The output will look like this:

````
masternode1 <IP>:<PORT> <Masternode private key> <TX> <INDEX>
````

## Configure and start Masternode

Let's first check if our transaction has at least 10 confirmations. You can do this by going to the **``Transactions Tab``** and just hover over the left icon of the transaction. If it has 10 confirmations you can continue, if not just wait a little longer for it to have at least 10.

**Step 1 - Get the tx and index**

In the wallets top menu, go to **``Help``** and select **``Debug window``**. Type in there ``masternode outputs`` and you will receive something in the following format:
````
{
  "75PvpMAfpweLLpyvZ5QidffsFAWYRMeiFgVs4NUYkna6hV4Vq" : "1"
}
````

This output translates to the following:

````
{
  "tx" : "index"
}
````

Now grab your **tx** and **index** and save it near the line you got from the install script on the **VPS**.

**Step 2 - Masternode config**

Open the masternode configuration file directly from the wallet by going to `Tools > Open Masternode Configuration File`. Open this with notepad on windows of textedit on mac.

Now enter the following line you saved from the VPS install script, on a **single line** that should look like this:

````
masternode1 <IP>:<PORT> <Masternode private key> <TX> <INDEX>
````

**And replace the <TX> and <INDEX> with the ones you got from the previous step**

Save the masternode configuration file and restart your wallet.



**Step 3 - Start masternode**

Click on the `Masternodes > My Masternodes` tab, select your masternode and click `Start alias`. You should now receive a message `Masternode has started successfully `.
