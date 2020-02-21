#!/bin/bash
echo "script start"
vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }

VM_NAME="MIDTERM4640"
NEW_VM_NAME="A01055260"
NET_NAME="NETMIDTERM"
SSH_PORT="12922"
WEB_PORT="12980"
CONFIG="midterm"

# Create Nat Network
create_network () {
    # creates the NAT network with port forwarding rules to the network
    vbmg natnetwork remove --netname "$NET_NAME"
    vbmg natnetwork add --netname "$NET_NAME" --network 192.168.10.0/24 \
    --dhcp off --ipv6 off --enable \
    --port-forward-4 "ssh:tcp:[]:$SSH_PORT:[192.168.10.10]:22" \
    --port-forward-4 "port80:tcp:[]:$WEB_PORT:[192.168.10.10]:80"
}

modify_vm(){
    # modifies the pxe vm to the newly created network
    vbmg modifyvm "$VM_NAME" --name "$NEW_VM_NAME" 
    vbmg modifyvm "$NEW_VM_NAME" --nat-network1 "$NET_NAME"
}

start_vm(){
    vbmg startvm "$NEW_VM_NAME"
}

check_connection(){
        while /bin/true; do
        ssh "$CONFIG" exit
        if [ $? -ne 0 ]; then
                echo "$NEW_VM_NAME server is not up, sleeping..."
                sleep 2
        else
                break
        fi
done
}

create_network
modify_vm
start_vm
check_connection

echo "done!"