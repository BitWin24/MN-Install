# BitWin24 Masternode Setup Script V1.0 for Ubuntu 16/18 LTS
#by mrx0rhk
#!/bin/bash
#
# Script will attempt to autodetect primary public IP address
# and generate masternode private key unless specified in command line
#
# Usage:
# bash bwi_mninstall.sh
#


declare -r COIN_NAME='bitwin24'
declare -r COIN_DAEMON="${COIN_NAME}d"
declare -r COIN_CLI="${COIN_NAME}-cli"
declare -r COIN_PATH='/usr/local/bin'
declare -r BOOTSTRAP_LINK='http://165.22.88.46/bwibootstrap.zip'
declare -r COIN_ARH='http://167.172.160.11/test/bitwin24-1.0.0-x86_64-linux-gnu.tar.gz'
declare -r COIN_TGZ=$(echo ${COIN_ARH} | awk -F'/' '{print $NF}')
declare -r CONFIG_FILE="${COIN_NAME}.conf"
declare -r CONFIG_FOLDER="${HOME}/.${COIN_NAME}"

#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#TCP port
PORT=24072
RPC=24071

#Clear keyboard input buffer
function clear_stdin { while read -r -t 0; do read -r; done; }

#Delay script execution for N seconds
function delay { echo -e "${GREEN}Sleep for $1 seconds...${NC}"; sleep "$1"; }

#Stop daemon if it's already running
function stop_daemon {
    if pgrep -x 'bitwin24d' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop bitwin24d${NC}"
        bitwin24-cli stop
        sleep 30
        if pgrep -x 'bitwin24d' > /dev/null; then
            echo -e "${RED}bitwin24d daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 bitwin24d
            sleep 30
            if pgrep -x 'bitwin24d' > /dev/null; then
                echo -e "${RED}Can't stop bitwin24d! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}

#Process command line parameters
genkey=$1
clear

echo -e "${GREEN} ---------- BitWin24 MASTERNODE INSTALLER -----------
 |                                                  |
 |                                                  |
 |       The installation will install and run      |
 |        the masternode under a user BitWin24.     |
 |                                                  |
 |        This version of installer will setup      |
 |           fail2ban and ufw for your safety.      |
 |                                                  |
 +--------------------------------------------------+
   ::::::::::::::::::::::::::::::::::::::::::::::::${NC}"
echo "Do you want me to generate a masternode private key for you? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "n" ]] ; then
          read -e -p "Enter your private key:" genkey;
              read -e -p "Confirm your private key: " genkey2;
    fi

#Confirming match
  if [ $genkey = $genkey2 ]; then
     echo -e "${GREEN}MATCH! ${NC} \a" 
else 
     echo -e "${RED} Error: Private keys do not match. Try again or let me generate one for you...${NC} \a";exit 1
fi
sleep .5
clear

# Determine primary public IP address
dpkg -s dnsutils 2>/dev/null >/dev/null || sudo apt-get -y install dnsutils
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ -n "$publicip" ]; then
    echo -e "${YELLOW}IP Address detected:" $publicip ${NC}
else
    echo -e "${RED}ERROR: Public IP Address was not detected!${NC} \a"
    clear_stdin
    read -e -p "Enter VPS Public IP Address: " publicip
    if [ -z "$publicip" ]; then
        echo -e "${RED}ERROR: Public IP Address must be provided. Try again...${NC} \a"
        exit 1
    fi
fi
if [ -d "/var/lib/fail2ban/" ]; 
then
    echo -e "${GREEN}Packages already installed...${NC}"
else
   echo -e "${GREEN}Updating system and installing required packages. This can take a few minutes...${NC}"

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y 2>/dev/null  >/dev/null 
sudo apt-get -y upgrade 2>/dev/null  >/dev/null 
sudo apt-get -y dist-upgrade 2>/dev/null  >/dev/null
sudo apt-get -y autoremove 2>/dev/null  >/dev/null
sudo apt-get -y install wget nano htop jq 2>/dev/null  >/dev/null
sudo apt-get -y install libzmq3-dev 2>/dev/null  >/dev/null
sudo apt-get -y install libevent-dev -y 2>/dev/null  >/dev/null
sudo apt-get install unzip 2>/dev/null  >/dev/null
sudo apt install unzip 2>/dev/null  >/dev/null
sudo apt -y install software-properties-common 2>/dev/null  >/dev/null
sudo add-apt-repository ppa:bitcoin/bitcoin -y 2>/dev/null  >/dev/null
sudo apt-get -y update 2>/dev/null  >/dev/null
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev -y 2>/dev/null  >/dev/null
sudo apt-get -y install libminiupnpc-dev 2>/dev/null  >/dev/null
sudo apt-get install -y unzip libzmq3-dev build-essential libssl-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libboost-system1.58.0 libboost1.58-all-dev libdb4.8++ libdb4.8 libdb4.8-dev libdb4.8++-dev libevent-pthreads-2.0-5 -y 2>/dev/null  >/dev/null 
   fi
   

#Network Settings
echo -e "${GREEN}Installing Network Settings...${NC}"
{
sudo apt-get install ufw -y
} &> /dev/null
echo -ne '[##                 ]  (10%)\r'
{
sudo apt-get update -y
} &> /dev/null
echo -ne '[######             ] (30%)\r'
{
sudo ufw default deny incoming
} &> /dev/null
echo -ne '[#########          ] (50%)\r'
{
sudo ufw default allow outgoing
sudo ufw allow ssh
} &> /dev/null
echo -ne '[###########        ] (60%)\r'
{
sudo ufw allow $PORT/tcp
sudo ufw allow $RPC/tcp
} &> /dev/null
echo -ne '[###############    ] (80%)\r'
{
sudo ufw allow 22/tcp
sudo ufw limit 22/tcp
} &> /dev/null
echo -ne '[#################  ] (90%)\r'
{
echo -e "${YELLOW}"
sudo ufw --force enable
echo -e "${NC}"
} &> /dev/null
echo -ne '[###################] (100%)\n'

#Generating Random Password for  JSON RPC
rpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

#Create 2GB swap file
if grep -q "SwapTotal" /proc/meminfo; then
    echo -e "${GREEN}Skipping disk swap configuration...${NC} \n"
else
    echo -e "${YELLOW}Creating 2GB disk swap file. \nThis may take a few minutes!${NC} \a"
    touch /var/swap.img
    chmod 600 swap.img
    dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
    mkswap /var/swap.img 2> /dev/null
    swapon /var/swap.img 2> /dev/null
    if [ $? -eq 0 ]; then
        echo '/var/swap.img none swap sw 0 0' >> /etc/fstab
        echo -e "${GREEN}Swap was created successfully!${NC} \n"
    else
        echo -e "${RED}Operation not permitted! Optional swap was not created.${NC} \a"
        rm /var/swap.img
    fi
fi
 
#Installing Daemon
echo -e "${GREEN}Downloading and installing BitWin24 deamon...${NC}"
cd ~
rm -rf /bitwin24-1.0.0
rm -rf /usr/local/bin/bitwin24*
wget ${COIN_ARH}
tar xvzf "${COIN_TGZ}"
cd /root/bitwin24-1.0.0/bin/  2>/dev/null  >/dev/null
sudo chmod -R 755 bitwin24-cli  2>/dev/null  >/dev/null
sudo chmod -R 755 bitwin24d  2>/dev/null  >/dev/null
cp -p -r bitwin24d /usr/local/bin  2>/dev/null  >/dev/null
cp -p -r bitwin24-cli /usr/local/bin  2>/dev/null  >/dev/null
bitwin24-cli stop  2>/dev/null  >/dev/null
rm ~/bitwin24-1.0.0-x86_64-linux-gnu.tar.gz*  2>/dev/null  >/dev/null
 
sleep 5
 #Create datadir
 if [ ! -f ~/.bitwin24/bitwin24.conf ]; then 
 	sudo mkdir ~/.bitwin24
 fi

cd ~
clear
echo -e "${YELLOW}Creating bitwin24.conf...${NC}"

# If genkey was not supplied in command line, we will generate private key on the fly
if [ -z $genkey ]; then
    cat <<EOF > ~/.bitwin24/bitwin24.conf
rpcuser=$rpcuser
rpcpassword=$rpcpassword
EOF

    sudo chmod 755 -R ~/.bitwin24/bitwin24.conf

    #Starting daemon first time just to generate a BitWin24 masternode private key
    bitwin24d -daemon > /dev/null
sleep 7
while true;do
    echo -e "${YELLOW}Generating masternode private key...${NC}"
    genkey=$(bitwin24-cli masternode genkey)
    if [ "$genkey" ]; then
        break
    fi
sleep 7
done
    fi
    
    #Stopping daemon to create bitwin24.conf
    bitwin24-cli stop
    sleep 5
    
#Adding bootstrap files 

cd ~/.bitwin24/ && rm -rf backups blocks chainstate debug.log .lock mncache.dat peers.dat staking zerocoin banlist.dat budget.dat db.log fee_estimates.dat mnpayments.dat  sporks *bootstrap*
cd ~/.bitwin24/ && wget ${BOOTSTRAP_LINK}
cd ~/.bitwin24/ && unzip bwibootstrap.zip

sleep 5 

cd ~/.bitwin24/ && rm -rf bwibootstrap.zip*


# Create bitwin24.conf
cat <<EOF > ~/.bitwin24/bitwin24.conf
rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcallowip=127.0.0.1
rpcport=$RPC
port=$PORT
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
masternode=1
externalip=$publicip
bind=$publicip
masternodeaddr=$publicip
masternodeprivkey=$genkey

addnode=167.172.160.11
addnode=104.238.158.145:24072
addnode=136.244.119.130:57102
addnode=140.82.36.220:24072
addnode=149.28.130.249:24072
addnode=155.138.137.24:24072
addnode=165.22.88.46:42262
addnode=178.238.227.138:24072
addnode=192.248.157.4:24072
addnode=199.247.17.226:24072
addnode=209.250.238.243:24072
addnode=217.163.23.164:40430
addnode=45.32.174.105:59466
addnode=45.32.235.148:24072
addnode=45.76.137.154:24072
addnode=45.77.140.126:40610
addnode=45.77.61.45:24072
addnode=66.42.54.81:24072
addnode=78.141.210.107:24072
addnode=79.231.94.182:49578
addnode=80.240.27.140:24072
addnode=81.169.154.116:24072
addnode=95.179.160.251:24072
 
EOF
    bitwin24d -daemon
#Finally, starting daemon with new bitwin24.conf
printf '#!/bin/bash\nif [ ! -f "~/.bitwin24/bitwin24.pid" ]; then /usr/local/bin/bitwin24d -daemon ; fi' > /root/bitwin24auto.sh

cd /root
sudo chmod 755 *.sh
#Setting auto start cron job for bitwin24
if ! crontab -l | grep "bitwin24auto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/bitwin24auto.sh")| crontab -
fi

echo -e "========================================================================
${GREEN}BitWin24 Masternode setup is complete!${NC}
========================================================================
Masternode was installed with VPS IP Address: ${GREEN}$publicip${NC}
Masternode Private Key: ${GREEN}$genkey${NC}
Now you can add the following string to the masternode.conf file 
======================================================================== \a"
echo -e "${GREEN}bitwin24_mn1 $publicip:$PORT $genkey TxId TxIdx${NC}"
echo -e "========================================================================
Use your mouse to copy the whole string above into the clipboard by
tripple-click + single-click (Dont use Ctrl-C) and then paste it 
into your ${GREEN}masternode.conf${NC} file and replace:
    ${GREEN}bitwin24_mn1${NC} - with your desired masternode name (alias)
    ${GREEN}TxId${NC} - with Transaction Id from masternode outputs
    ${GREEN}TxIdx${NC} - with Transaction Index (0 or 1)
     Remember to save the masternode.conf and restart the wallet!
To introduce your new masternode to the BitWin24 network, you need to
issue a masternode start command from your wallet, which proves that
the collateral for this node is secured."

clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e "Wait for the node wallet on this VPS to sync with the other nodes
on the network. Eventually the 'Is Synced' status will change
to 'true', which will indicate a complete sync, although it may take
from several minutes to several hours depending on the network state.
Your initial Masternode Status may read:
    ${GREEN}Node just started, not yet activated${NC} or
    ${GREEN}Node  is not in masternode list${NC}, which is normal and expected.
"
clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e "
${GREEN}...scroll up to see previous screens...${NC}
Here are some useful commands and tools for masternode troubleshooting:
========================================================================
To view masternode configuration produced by this script in bitwin24.conf:
${GREEN}cat ~/.bitwin24/bitwin24.conf${NC}
Here is your bitwin24.conf generated by this script:
-------------------------------------------------${GREEN}"
echo -e "${GREEN}bitwin24_mn1 $publicip:$PORT $genkey TxId TxIdx${NC}"
cat ~/.bitwin24/bitwin24.conf
echo -e "${NC}-------------------------------------------------
NOTE: To edit bitwin24.conf, first stop the bitwin24d daemon,
then edit the bitwin24.conf file and save it in nano: (Ctrl-X + Y + Enter),
then start the bitwin24d daemon back up:
to stop:              ${GREEN}bitwin24-cli stop${NC}
to start:             ${GREEN}bitwin24d${NC}
to edit:              ${GREEN}nano ~/.bitwin24/bitwin24.conf ${NC}
to check mn status:   ${GREEN}bitwin24-cli masternode status${NC}
========================================================================
To monitor system resource utilization and running processes:
                   ${GREEN}htop${NC}
========================================================================

${GREEN}Have fun with your BitWin24 Masternode!${NC}

${RED}BitWin24 - the first real Blockchain Lottery${NC} 

"
rm ~/bwi_mninstall.sh
