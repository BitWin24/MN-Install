
## Single masternode on Linux VPS + cold control wallet on local PC
------
This guide is for a single masternode, on a Ubuntu 16.04 64bit server(1GB RAM) and will be controlled from the wallet on your local computer.

First the basic requirements:
* 3000 BWI 
* A main computer(Your everyday computer)
* Masternode Server(The computer that will be on 24/7)
* A unique IP address for EACH masternode

The basic reasoning for these requirements is that, you get to keep your BWI in your local wallet, and host your masternode remotely, securely.

For this guide, I’m going to refer to your main computer’s wallet as the main wallet, and the masternode wallet as the masternode wallet.

-------

### I. Deploy VPS and configuration

1. Get a VPS server with min. 1GB RAM and Ubuntu 16.04 as operating system
2. Get PUTTY for your operating system from https://www.putty.org
    * Always use mouse selection for COPY text from PUTTY to WINDOWS
    * Always use right button click for PASTE text in PUTTY from WINDOWS
3. RUN script bellow(select from below, COPY, PASTE in Putty and press ENTER):

   ``` 
   wget https://raw.githubusercontent.com/BitWin24/guides/master/bwi_mninstall
   sudo chmod +x bwi_mninstall.sh
   ./bwi_mninstall.sh```
    
(It may take 2-3 minutes. It will automatically install and configure masternode wallet for your masternode server!)

4. Note the configuration line in Notepad(text file)! - We’ll use this later…

--------

### II. Install main wallet and configuration

1. Go to https://bitwin24.io/ and download wallet for your windows
2. Unpack it and launch ***bitwin24-qt.exe***
3. Select "Use standard directory" 
4. SETTINGS -> OPTIONS -> WALLET and check "Show Masternodes Tab". Press OK and restart main wallet
5. TOOLS -> DEBUG CONSOLE and type the following command:
   ```getaccountaddress mn1```
6. Send 3000 BWI to this address.(Make sure this is 100% only 3000; No less, no more.) and wait for 15 confirmations
7. Still in the main wallet, enter the command into the console:
   ```masternode outputs``` (This gets the proof of transaction of sending 3000)
8. Still on the main computer, go into the BitWin24 data directory(%appdata%/Bitwin24)
   Find masternode.conf and add the following line to it:   
   
   ```<Name of Masternode(Use the name you entered earlier for simplicity)> <config line from VPS setup> >The result of Step I.4> <Result of Step II.7> <The number after the long line in Step II.7>```
   
   ***Substitute it with your own values and without the “<>”s***
   
   Example:
   
   ```mn1 10.10.10.10:39105 5j31NEU4Mw629r9SQLiqctuAody3BL8E9tW3aQD7wR2bA2AzQhh e629899c90494cf2a0b8935bece819480db0749b59e0d65ffb55c9bffaed5f99 1```
   

9. Save it, close and restart the main wallet. **Wait for full sync**.
10. Masternodes tab -> Start all
   
#### *Congratulations! You have successfully created your masternode!*
