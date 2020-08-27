#Update Masternode Script by mrx0rhk
#This Script updates the bitwin24 Masternode to the newest Version


declare -r COIN_NAME='bitwin24'
declare -r COIN_DAEMON="${COIN_NAME}d"
declare -r COIN_CLI="${COIN_NAME}-cli"
declare -r COIN_PATH='/root/bitwin24_debug/bitwin24-1.0.0/bin/'
declare -r BOOTSTRAP_LINK='http://165.22.88.46/bwibootstrap.zip'
declare -r COIN_ARH='http://167.172.160.11/test/bitwin24-1.0.0-x86_64-linux-gnu-debug.tar.gz'
declare -r COIN_ARCH='http://167.172.160.11/test/bitwin24-1.0.0-x86_64-linux-gnu.tar.gz'
declare -r COIN_TGZ_DEBUG=$(echo ${COIN_ARH} | awk -F'/' '{print $NF}')
declare -r COIN_TGZ=$(echo ${COIN_ARCH} | awk -F'/' '{print $NF}')
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

killall bitwin24d 2>/dev/null  >/dev/null
killall bitwin24d 2>/dev/null  >/dev/null
killall bitwin24d 2>/dev/null  >/dev/null

#Process command line parameters
genkey=$1
clear

echo -e "${GREEN} 
  ---------- BitWin24 MASTERNODE UPDATER -----------
 |                                                  |
 |                                                  |
 |          The installation will update            |
 |            your BitWin24 Masternode!             |
 |                                                  |
 |            The privatekey and other data         |
 |               will not be touched!               |
 |                                                  |
 +--------------------------------------------------+
   ::::::::::::::::::::::::::::::::::::::::::::::::${NC}"
echo "Do you want to update your BitWin24 Masternode? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "n" ]] ; then
          exit 1
    fi
    
killall bitwin24d 2>/dev/null  >/dev/null
killall bitwin24d 2>/dev/null  >/dev/null
killall -9 bitwin24d 2>/dev/null  >/dev/null

sleep 10
clear

#updating Daemon
cd ~
systemctl stop $COIN_NAME.service
$COIN_NAME-cli stop

rm -rf bitwin24-1.0.0-x86_64-linux-gnu-debug*
rm -rf bitwin24-1.0.0
rm -rf /usr/local/bin/bitwin24*
rm -rf *tar.gz
mkdir bitwin24_debug
cd bitwin24_debug
wget ${COIN_ARH}
tar xvzf "${COIN_TGZ_DEBUG}"
wget ${COIN_ARCH}
tar xvzf "${COIN_TGZ}"

cd /root/bitwin24_debug/
rm *.tar.gz*

cd /root/bitwin24_debug/bitwin24-1.0.0/bin/  2>/dev/null  >/dev/null
sudo chmod -R 755 bitwin24-cli  2>/dev/null  >/dev/null
sudo chmod -R 755 bitwin24d  2>/dev/null  >/dev/null
cp -p -r bitwin24d /root/bitwin24_debug/bitwin24-1.0.0/bin  2>/dev/null  >/dev/null
cp -p -r bitwin24-cli /root/bitwin24_debug/bitwin24-1.0.0/bin  2>/dev/null  >/dev/null
bitwin24-cli stop  2>/dev/null  >/dev/null

cd ~

#Adding bootstrap files 

cd ~/.bitwin24/
rm -rf backups blocks chainstate database *.pid debug.log .lock peers.dat staking zerocoin banlist.dat budget.dat db.log fee_estimates.dat mnpayments.dat sporks mnwitness bwibootstrap*
cd ~/.bitwin24/ && wget ${BOOTSTRAP_LINK}
rm -rf backups blocks chainstate database *.pid debug.log .lock peers.dat staking zerocoin banlist.dat budget.dat db.log fee_estimates.dat mnpayments.dat sporks mnwitness
cd ~/.bitwin24/ && unzip bwibootstrap.zip
rm -rf bwibootstrap.zip*
cd ~

sleep 5
 
#config service

 cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=root
Group=root
Type=forking
#PIDFile=$CONFIG_FOLDER/$COIN_NAME.pid
ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIG_FOLDER/$CONFIG_FILE -datadir=$CONFIG_FOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIG_FOLDER/$CONFIG_FILE -datadir=$CONFIG_FOLDER stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl enable $COIN_NAME.service
  systemctl start $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
  


echo -e "
${GREEN}...Masternode successfully updated!...${NC}

When the blockchain is fully synced start your masternode in the control wallet !

Here are some useful commands and tools for wallet troubleshooting:
========================================================================
To view wallet configuration produced by the first script in bitwin24.conf:
${GREEN}cat ~/.bitwin24/bitwin24.conf${NC}
Here is your bitwin24.conf generated by this script:
-------------------------------------------------${GREEN}"
echo -e ""
cat ~/.bitwin24/bitwin24.conf
echo -e "${NC}-------------------------------------------------
NOTE: To edit bitwin24.conf, first stop the bitwin24d daemon,
then edit the bitwin24.conf file and save it in nano: (Ctrl-X + Y + Enter),
then start the bitwin24d daemon back up:
to stop:              ${GREEN}./bitwin24_debug/bitwin24-1.0.0/bin/bitwin24-cli stop${NC}
to start:             ${GREEN}./bitwin24_debug/bitwin24-1.0.0/bin/bitwin24d${NC}
to edit:              ${GREEN}nano ~/.bitwin24/bitwin24.conf ${NC}
to check status:      ${GREEN} watch ./bitwin24_debug/bitwin24-1.0.0/bin/bitwin24-cli getinfo ${NC}
to check MN status:   ${GREEN} watch ./bitwin24_debug/bitwin24-1.0.0/bin/bitwin24-cli masternode status ${NC}
========================================================================
To monitor system resource utilization and running processes:
                   ${GREEN}htop${NC}
========================================================================
${GREEN}Have fun with your BitWin24 Masternode!${NC}

${RED}BitWin24 - the first real Blockchain Lottery${NC} 
"
