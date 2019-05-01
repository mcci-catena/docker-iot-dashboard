# Setting up a server

First you have to choose a cloud provider and install Docker and Docker-Compose. That's very much provider dependent.

## On Digital Ocean

_Last Update: 2019-04-30_

### Create droplet

1. Log in at [Digital Ocean](https://cloud.digitalocean.com/)

2. Create a new project (if needed) to hold your new droplet.

3. Discover > Marketplace, search for `Docker`

4. You shoud come to this page: https://cloud.digitalocean.com/marketplace/5ba19751fc53b8179c7a0071?i=ec3581

5. Press "Create"

6. Select the standard 8G GB Starter that is selected.

7. Choose a datacenter; I chose New York.

8. Additional options: none.

9. Add your SSH keys.

10. Choose a host name, e.g. `passivehouse-ecovillage`.

11. Select your project.

12. Press "Create"

### Configure droplet

1. Note the IP address from above.

2. `ssh root@{ipaddress}`

3. Remove the motd.

4. Add user:

   ```shell
   adduser username
   adduser username admin
   adduser username docker
   adduser username plugdev
   adduser username staff
   ```

5. Disable root login via SSH or via password

6. Optional: enable `username` to sudo without password.

   ```shell
   sudo VISUAL=vi visudo
   ```

   Add the following line at the bottom:

   ```sudoers
   username ALL=(ALL) NOPASSWD: ALL
   ```

7. Test that you can become `username`:

   ```console
   # sudo -i username
   username@host-name:~$
   ```

8. Drop back to root, and then copy the authorized_keys file to `~username`:

   ```shell
   mkdir -m 700 ~username/.ssh
   cp -p .ssh/authorized_keys ~username/.ssh
   chown -R username.username ~username/.ssh/authorized_keys
   ```

9. See if you can ssh in.

10. Optional: set up byobu by default:

   ```shell
   byobu
   byobu-enable
   ```

11. Set the host name.

   ```shell
   vi /etc/hosts
   ```

   Change the line `127.0.1.1 name name` to `127.0.0.1 myhost.myfq.dn myhost`.

12. If needed, use `hostnamectl` to set the static hostname to match `myhost`.

13. set up Git:

   ```shell
   sudo add-apt-repository ppa:git-core/ppa
   sudo apt update
   sudo apt install git
   ```

14. We'll put the docker filess at `/opt/docker/docker-ttn-dashboard`, setting up as follows:

   ```shell
   sudo mkdir /opt/docker
   cd /opt/docker
   sudo chgrp admin .
   sudo chmod g+w .
   ```

## After server is set up

1. Clone this repo.

   ```shell
   git clone git clone git@github.com:mcci-catena/docker-ttn-dashboard.git
   ```

2. move to that repo

   ```shell
   cd /opt/docker/docker-ttn-dashboard
   ```

3. Make sure that you have the following tools installed on the host server.

   Tool|On Ubuntu|On CentOS 7
   ----|---------|-----------
   `htpasswd`|`sudo apt-get install apache2-utils`|`sudo yum install httpd-tools`

4. Get a fully-qualified domain name (FQDN) for your server, for which you control DNS. Point it to your server. Make sure it works.

4. Create a `.env` file as instructed in README.md. To get a template:

   ```shell
   sed -ne '/^#+++/,/^#---/p' -e '/#[^ \t]/d' docker-compose.yml
   ```

5. Using `docker-compose run apache /bin/bash`:
   * If this fails with the message, `ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?`, then probably your user ID is not in the `docker` group. To fix this, `sudo adduser MYUSER docker`, where "MYUSER" is your login ID. Then (**very important**) log out and log back in.

   1. Add Apache's `/etc/apache2/authdata` as user www-data
   ```sh
	chown www-data /etc/apache2/authdata
   ```
   2. Add Apache's `/etc/apache2/authdata/.htpasswd`.
   ```sh
	touch /etc/apache2/authdata/.htpasswd
	chown www-data /etc/apache2/authdata/.htpasswd
   ```
   3. Add user logins for node-red and influxdb queries. Make `USERS` be a list of login IDs.
   ```sh
	export USERS="tmm amy josh"
	for USER in $USERS; do echo "Set password for "$USER; htpasswd /etc/apache2/authdata/.htpasswd $USER; done
   ```
   4. Add Apache's `/etc/apache2/authdata/.htgroup`.
   ```sh
	# this assumes USERS is still set from previous step.
	touch /etc/apache2/authdata/.htgroup
	chown www-data /etc/apache2/authdata/.htgroup
	echo "node-red: ${USERS}" >>/etc/apache2/authdata/.htgroup
	echo "query: ${USERS}" >>/etc/apache2/authdata/.htgroup
   ```
   5. Exit Apache's container with Ctrl-D.
