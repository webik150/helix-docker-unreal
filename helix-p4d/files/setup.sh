#!/bin/bash
$FRESH = 0
if [ ! -d "$P4ROOT/etc" ]; then
    echo >&2 "First time installation, copying configuration from /etc/perforce to $P4ROOT/etc and relinking"
    mkdir -p "$P4ROOT/etc"
    cp -r /etc/perforce/* "$P4ROOT/etc/"
	$FRESH = 1
fi

mv /etc/perforce /etc/perforce.orig
ln -s "$P4ROOT/etc" /etc/perforce

if ! p4dctl list 2>/dev/null | grep -q "$NAME"; then
    /opt/perforce/sbin/configure-helix-p4d.sh "$NAME" -n -p "$P4PORT" -r "$P4ROOT" -u "$P4USER" -P "${P4PASSWD}" --case 1 --unicode
fi

if [ "$FRESH" = 1 ]; then
    (p4 typemap -o; echo " binary+w //depot/....exe") | p4 typemap -i
    (p4 typemap -o; echo " binary+w //depot/....dll") | p4 typemap -i
    (p4 typemap -o; echo " binary+w //depot/....lib") | p4 typemap -i
    (p4 typemap -o; echo " binary+w //depot/....app") | p4 typemap -i
    (p4 typemap -o; echo " binary+w //depot/....dylib") | p4 typemap -i
    (p4 typemap -o; echo " binary+w //depot/....stub") | p4 typemap -i
    (p4 typemap -o; echo " binary+w //depot/....ipa") | p4 typemap -i
    (p4 typemap -o; echo " binary //depot/....bmp") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....ini") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....config") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....cpp") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....h") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....c") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....cs") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....m") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....mm") | p4 typemap -i
    (p4 typemap -o; echo " text //depot/....py") | p4 typemap -i
    (p4 typemap -o; echo " binary+l //depot/....uasset") | p4 typemap -i
    (p4 typemap -o; echo " binary+l //depot/....umap") | p4 typemap -i
    (p4 typemap -o; echo " binary+l //depot/....upk") | p4 typemap -i
    (p4 typemap -o; echo " binary+l //depot/....udk") | p4 typemap -i
	$FRESH = 0
fi

p4 configure set $P4NAME#server.depot.root=$P4DEPOTS
p4 configure set $P4NAME#journalPrefix=$P4CKP/$JNL_PREFIX

p4dctl start -t p4d "$NAME"
