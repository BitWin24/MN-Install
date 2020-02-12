# asking for permission to run script

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

# stopping wallet

cd ~
bitwin24-cli stop
sleep 5

# downloading bootstrap

cd ~/.bitwin24/ && rm -rf blocks chainstate sporks zerocoin peers.dat
cd ~/.bitwin24/ && wget https://www.dropbox.com/s/mg606h8lqgwqk5m/bootstrap.zip
cd ~/.bitwin24/ && unzip bootstrap.zip


# starting wallet

bitwin24d -daemon

echo -e "========================================================================
${GREEN}Bootstrap added!${NC}
========================================================================
to check status type 

${GREEN}bitwin24-cli masternode status${NC}

or

${GREEN}bitwin24-cli getinfo${NC}

========================================================================"

cd ~ && rm -rf bwi_bootstrap.sh 
cd ~/.bitwin24/ && rm bootstrap.zip
