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

cd ~/.bitwin24/ && rm -rf blocks chainstate sporks zerocoin
cd ~/.bitwin24/ && wget https://github.com/BitWin24/guides/raw/master/BITWIN24-bootstrap15012020.zip
cd ~/.bitwin24/ && unzip BITWIN24-bootstrap15012020.zip

# starting wallet

bitwin24d -daemon

echo -e "========================================================================
${GREEN}Bootstrap added!${NC}
========================================================================
to check status type 

${GREEN}bitwin24-cli masternode status${NC}

or

${GREEN}bitwin24-cli getinfo${NC}

========================================================================
