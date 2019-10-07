This is an Ansible playbook to install and configure Foreman and Foreman Smart Proxies. This playbook was designed to be an easy way to get Foreman/Foreman Proxies installed and configured for provisioning.

## Requirements
- 4GB RAM minimum for Foreman server and proxies
- FQDN should be used
- CentOS 7.x (I have only tested on CentOS7, selinux disabled)

## Installation

- Copy group_vars/all.yml.sample to group_vars/all.yml and edit accordingly. The defaults will get a Foreman instance up and running and ready to provision.
- Edit inventory with correct hostnames
- Run playbook. For example, to run foreman only, run:  ansible-playbook install-foreman.yml

Notes:
When creating installation media, use "media-server" for the hostname. This will use the media server local to the provisioning subnet the client is connected to. For instance, in the Path field, use http://media-server:81/media/centos7-1810/

On dual-homed proxies, this should be the IP adddress associated with the isolated network. 

There is a cron job that runs the script /opt/scripts/sync_media.sh every minute that will check the /opt/iso directory on the foreman server and will create the directories (based on the filename) and will extract the iso and  copy the contents to every smart proxy. All you need to do is copy the .iso file to the foreman server (/opt/iso). You can also add any file or directory to the foreman server (/opt/media-library) and this directory synchronizes with all smart proxies ( accessed at http://media-server:81/media).

This playbook will add an entry in the local hosts on the smart proxy called "smart-proxy". This will resolve to the smart proxys' IP address (look at the inventory sample). You will need to update the discovery scripts and change the proxy.url and proxy.type to the following: proxy.url=https://smart-proxy:8443 proxy.type=proxy

This allows the discovered hosts to use the correct proxy.
