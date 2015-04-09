#! /bin/sh
function randpass() {
  [ "$2" == "0" ] && CHAR="[:alnum:]" || CHAR="[:graph:]"
    cat /dev/urandom | tr -cd "$CHAR" | head -c ${1:-32}
    echo
}
sudo apt-get install nodejs git build-essential devscripts debhelper
echo -n "
================================================================================
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                         In Case of Police State                            !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
================================================================================"
echo -n "
Welcome to \"In Case of Police State,\" a script to help individuals administer
nodes on an independently owned and operated routing network. First, it's not
seriously intended to help in case of a police state, but it's a catchy name and
who the heck knows. There's a new ball game in the private messaging biz every
week. What this script does is configures a Debian GNU/Linux host with a mesh
router using the brilliant Caleb James Delisle's Network Suite(cjdns) and
selecting interfaces for you to use to route requests using whatever networking
hardware you have available. This way, if you have 2 Wi-Fi cards, one can accept
clients and one can set up connections to the rest of the network. Also If you 
have internet access, you can share it with clients and other mesh nodes and 
provide VPN access to the regular internet. The goal with this script is to get
as much coverage as possible, with a reliable basic level of encryption,
from what can be found on a pretty typical Debian or Ubuntu laptop. Once it's
done that, it will offer a menu of basic services which you can choose to host
on your device, like https servers, email servers, and jabber servers(although
almost any service can be hosted on cjdns, this script simply attempts to 
automate that for admins in the short-term.
"
echo -n "First check and make sure the user can make https connections to github
(To Be implemented.) If not, fall back to installing the bare-minimum working
system from the source downloaded in this repository(also to be implemented),
attempt to establish a mesh connection(also also to be implemented), and
immediately prompt to re-run this script to download pertinent updates.
"
FALLBACK='false'
echo -n "
If you would like to use a personal github fork, you can do so by entering your
github username now. This requires you to have already forked cjdns under your
github username. If you don't want to use a github fork, you can safely ignore
this. If you do want to use a github fork, you should not that this script will
merge upstream changes by default. Users who do not wish to merge upstream 
changes can do so by editing their update.sh file and commenting out the lines
git fetch upstream
and
git merge upstream/master
RUNNING install.sh WILL ALWAYS MERGE UPSTREAM CHANGES. If you do not want to
merge upstream changes, alter your update.sh file and use it instead."
read GITHUBUSER
DIRECTORY=$HOME:'cjdns'
if [ -d "$DIRECTORY" ]; then
	cd cjdns
	git fetch upstream
	git checkout master
	git merge upstream/master
	git pull
else
	if [ "$GITHUBUSER" == '' ]; then
		git clone https://github.com/cjdelisle/cjdns.git
		cd cjdns
		echo "#! /bin/sh
cd cjdns
git pull
debuild
sudo dpkg -i ../cjdns.deb
" > update.sh
	else
		CUSTOMREPO='https://github.com/':"$GITHUBUSER":'/cjdns.git'
		cd cjdns
		git clone "$CUSTOMREPO"
		git remote add upstream https://github.com/cjdelisle/cjdns.git
		git fetch upstream
		git merge upstream/master
		git pull
		echo "#! /bin/sh
EKK='The custom repository used for this installation was:'
GIT=$CUSTOMREPO
":'
echo $EKK
echo $GIT
cd cjdns
git fetch upstream
git merge upstream/master
git pull
debuild
sudo dpkg -i ../cjdns.deb
' > update.sh
	fi
fi
echo -n "
!! CONGRATULATIONS! You are about to install cjdns on your computer and be a
little closer to a liberated, secure internet. First, we need to let you know 
some things. First, you are a peer on this network, which means that for the
purposes of cjdns, any services you host will be available to the network. Since
you're doing this, you probably want to host some services, but we're going to
just go ahead and close all the ports on the tunnel cjdns is using. You will
need to open the ports for services you want to host over cjdns. Is that 
OK?[Y/N](default Y)"
read FIREWALL
if [ "$FIREWALL" == 'N']; then
	echo -n "You have chosen not to configure your firewall by default for
cjdns. Do you still want to install it(At your own risk)?[Y/N](Default N)"
	read ACCEPT
	if [ "$ACCEPT" == 'Y']; then
		debuild
		sudo dpkg -i ../cjdns*.deb
		sudo useradd cjdns
		cjdroute --genconf > cjdroute.conf
		cjdroute --cleanconf < cjdroute.conf > cjdroute.json && rm cjdroute.conf
		temp='"type" : "TUNInterface"'
		temp2='"type" : "TUNInterface"
	"tunDevice" : "cjdroute0"
'
		sed -i e "s/$temp/$temp2/g" cjdroute.conf		
		sed -i e 's/nobody/cjdns/g' cjdroute.conf
		temp=`cat cjdroute.conf | grep ipv6`
		temp2=`echo "$temp" | tr -d ' ,"'`
		CJDIP6=`sed 's/ipv6://g' <<< $temp2`
		echo -n "ipv6 address of cjdns host detected as:$CJDIP6"
		chown cjdns:cjdns cjdroute.conf
		sudo -u cjdns chmod 600 cjdroute.conf
		sudo ln -s cjdroute.conf /etc/cjdroute.conf
		sudo ip tuntap add mode tun user cjdns dev cjdroute0
		sudo ip addr add $CJDIP6 dev cjdroute0
		sudo ip link set mtu 1312 dev cjdroute0
		sudo ip link set cjroute0 up
		echo -n 'modifying rc.local for to configure cjdns user tunnel'
		sudo sed -i -e "1d" /etc/rc.local
		echo '#! /bin/sh -e':"
sudo ip addr add $CJDIP6 dev cjdroute0":
'sudo ip link set mtu 1312 dev cjdroute0
sudo ip link set cjroute0 up
' | cat - /etc/rc.local > temp && sudo mv temp /etc/rc.local && sudo chmod +x /etc/rc.local
	fi
else
	debuild
	sudo dpkg -i ../cjdns*.deb
	sudo useradd cjdns
	cjdroute --genconf > cjdroute.conf
	cjdroute --cleanconf < cjdroute.conf > cjdroute.json && rm cjdroute.conf
	temp='"type" : "TUNInterface"'
	temp2='"type" : "TUNInterface"
	"tunDevice" : "cjdroute0"
'
	sed -i e "s/$temp/$temp2/g" cjdroute.conf
	sed -i e 's/nobody/cjdns/g' cjdroute.conf
	temp=`cat cjdroute.conf | grep ipv6`
	temp2=`echo "$temp" | tr -d ' ,"'`
	CJDIP6=`sed 's/ipv6://g' <<< $temp2`
	echo -n "ipv6 address of cjdns host detected as:$CJDIP6"
	chown cjdns:cjdns cjdroute.conf
	sudo -u cjdns chmod 600 cjdroute.conf
	sudo ln -s cjdroute.conf /etc/cjdroute.conf
	sudo ip tuntap add mode tun user cjdns dev cjdroute0
	sudo ip addr add $CJDIP6 dev cjdroute0
	sudo ip link set mtu 1312 dev cjdroute0
	sudo ip link set cjroute0 up
	sudo sed -i -e "1d" /etc/rc.local
	echo -n 'modifying rc.local for to configure cjdns user tunnel'
	echo '#! /bin/sh -e':"
sudo ip addr add $CJDIP6 dev cjdroute0":
'sudo ip link set mtu 1312 dev cjdroute0
sudo ip link set cjroute0 up
' | cat - /etc/rc.local > temp && sudo mv temp /etc/rc.local && sudo chmod +x /etc/rc.local
fi
echo -n "Now we're going to set you up to be a meshlocal. To do this we're going
to need an interface to use. If you want to use the default interface, just
leave the field blank. 
If you want to use your ethernet interface to connect with your peers, you can 
also probably leave it blank, unless your ethernet interface isn't named eth0.
If your desired interface is not named eth0, enter the name of the physical 
interface you want to use(eth1, wlan0, etc). Really try not to make a mistake,
it's not checking for you yet.
"
read ETHERFACE
if ["$ETHERFACE"==''];then
else
	sed -i e "s/eth0/$ETHERFACE/g" cjdroute.conf
fi
echo -n "Awesome. Now that we've got all that taken care of, lets find you
somebody cool to configure you a as a peer and give you access to the network.
Hey! You know what all the cool kids are doing? They're setting up port 
forwarding and configuring ddclient to so they can help people join the network
from the internet. You want to be cool, don't you? No but seriously, this is a
setup most folks aren't that used to, it might very well be ill-advised, but 
here's what it is. 

If you should choose to run this part of the script, you will
be signed up for a dynamic DNS account using a temporary email account, and the
configuration details of that account will be put into a ddclient.conf file, 
which will then be used to update your public IP address so that people using
your peer to connect to the network will be able to find it should the location
of your node change. 

The side effect of this is that your computer now is addressable on the regular
internet using this dynamic domain name, which potentially exposes a greater
potential attack surface. If you should choose to help people connect to the
network in this way, we ask that you please, please take great care to keep your
internet facing services up to date, keep your outgoing firewall on a white-list
only basis, and take any other precautions you can for the servies you choose to
offer. Of course I can't make you. But like, I'm pretty sure there's going to be
at least a little doubt about this idea, if not like, somebody pissed off."
echo -n "
!! So, do you want to do what the cool kids do and configure ddclient and host
cjdns for others?[Y/N](default N, but if you wanna do us a favor...)"
read DDCLIENT
if ["$DDCLIENT"=='Y']; then
	sudo apt-get install ddclient
	echo -n "Do you want to randmize all the dynamic dns information for 
your node?"
	read RANDOMIZE
	if ["$RANDOMIZE"=='Y']; then
		RAND=randpass()
		temp=`wget --post-data "m=$RAND" -q -r -l 5 -O - http://www.dispostable.com/inbox/$RAND/ | grep -E -o "\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b"`
		temp2=sed -i -e '$ d' <<< $temp
		temp='0000000'
		DDEMAIL=sort $temp2 | uniq -u
		DDPASS= randpass()
		wget --post-data "email=$DDEMAIL&password=$DDPASS&password2=$DDPASS" https://dnsdynamic.com/signup.php
	else
		echo -n "What email do you want to use for dynamic DNS?"
		read DDEMAIL
		echo -n "What password do you want to use for dynamic DNS?"
		read DDPASS
		echo -n "confirm"
		read DDPASS2
		if ["$DDPASS"=="$DDPASS2"]; then
			wget --post-data "email=$DDEMAIL&password=$DDPASS&password2=$DDPASS2" https://dnsdynamic.com/signup.php
		fi

	fi
	echo "
 daemon=600                               # check every 600 seconds
 syslog=no                              # log update msgs to syslog
 mail=root                               # mail all msgs to root
 mail-failure=root                       # mail failed update msgs to root
 pid=/var/run/ddclient.pid               # record PID in file.
 ssl=yes                                 # use ssl-support.  Works with
                                         # ssl-library
 use=web, web=myip.dnsdynamic.com        # get ip from server.
 server=www.dnsdynamic.org               # default server
 login=$DDEMAIL@dispostable.com          # default login
 password=$DDPASS               	 # default password
 server=www.dnsdynamic.org,              \
 protocol=dyndns2                        \
 $DDEMAIL.dnsdynamic.com
"> ddclient.conf
	mv ddclient.conf /etc/ddclient.conf
fi
echo -n "M
"
echo -n "
================================================================================
!!   All right we're all finished. It is reccommended that you go ahead and   !!
!!    restart your computer. If you want to do so, type \"YES\"(all caps)     !!
================================================================================
"
read SHUTDOWN
if ["$SHUTDOWN"=='YES'];then
	sudo shutdown -r now
fi
