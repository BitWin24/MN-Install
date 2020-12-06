# asking for permission to run script

declare -r BOOTSTRAP_LINK='http://165.22.88.46/bwibootstrap.zip'



clear 

echo -e "${GREEN} ---------- BitWin24 BOOTSTRAP INSTALLER -----------
 |                                                  |
 |                                                  |
 |       The script will add blockchain files       |
 |       for a faster syncing BitWin24 wallet       |
 |                                                  |
 |        The wallet will be closed and started     |
 |                   automatically                  |
 |                                                  |
 +--------------------------------------------------+
   ::::::::::::::::::::::::::::::::::::::::::::::::${NC}"
echo "Do you want to add the BitWin24 Bootstrap? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "n" ]] ; then
          exit 1
    fi

sleep .5
clear

# stopping wallet and installing unzip

cd ~
rm -rf bitwin24-0.0.*
bitwin24-cli stop
systemctl stop bitwin24.service
sleep 5
apt install unzip -y

# downloading bootstrap


rm bwi_bootstrap*
cd ~/.bitwin24/
rm -rf blocks chainstate debug.log .lock mncache.dat peers.dat staking banlist.dat budget.dat db.log fee_estimates.dat mnpayments.dat sporks mnwitness *bootstrap*
cd ~/.bitwin24/ && wget ${BOOTSTRAP_LINK}
cd ~/.bitwin24/ && unzip bwibootstrap.zip

rm bootstrap.zip*


rm -rf bootstrap*

# starting wallet

systemctl start bitwin24.service

echo -e "========================================================================
${GREEN}Bootstrap added!${NC}
========================================================================
to check status type 

${GREEN}bitwin24-cli masternode status${NC}

or

${GREEN}bitwin24-cli getinfo${NC}

========================================================================"
cd ~
rm bwi_bootstrap.sh*
