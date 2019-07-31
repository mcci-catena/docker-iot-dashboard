# Set-by-step Setup Instructions
<!-- markdownlint-disable MD034 -->
<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
<!-- TOC depthFrom:2 updateOnSave:true -->

- [Notes](#notes)
- [Cloud-Provider Setup](#cloud-provider-setup)
	- [On Digital Ocean](#on-digital-ocean)
		- [Create droplet](#create-droplet)
		- [Configure droplet](#configure-droplet)
- [After server is set up](#after-server-is-set-up)
	- [Create and edit the `.env` file](#create-and-edit-the-env-file)
	- [Set up the Node-RED and InfluxDB API logins](#set-up-the-node-red-and-influxdb-api-logins)
- [Start the server](#start-the-server)
	- [Restart servers in the background](#restart-servers-in-the-background)
	- [Initial testing](#initial-testing)
		- [Set up first data source](#set-up-first-data-source)
	- [Test Node-RED](#test-node-red)
	- [Creating an InfluxDB database](#creating-an-influxdb-database)
- [Add Apache log in for NodeRed or query after the fact](#add-apache-log-in-for-nodered-or-query-after-the-fact)

<!-- /TOC -->
<!-- markdownlint-restore -->
<!-- Due to a bug in Markdown TOC, the table is formatted incorrectly if tab indentation is set other than 4. Due to another bug, this comment must be *after* the TOC entry. -->

## Notes

Throughout the following, we assume you're creating a dashboard server named `dashboard.example.com`. Change this to whatever you like. For convenience, we name other things consistently:

`/opt/docker/dashboard.example.com` is the directory (on the host system) containing the docker files.

`/var/opt/docker/dashboard.example.com` is the directory (on the host system) containing persistent data.

We assume that you're familiar with Node-RED.

## Cloud-Provider Setup

First you have to choose a cloud provider and install Docker and Docker-Compose. That's very much provider dependent.

### On Digital Ocean

_Last Update: 2019-07-31_

#### Create droplet

1. Log in at [Digital Ocean](https://cloud.digitalocean.com/)

2. Create a new project (if needed) to hold your new droplet.

3. Discover > Marketplace, search for `Docker`

4. You should come to this page: https://cloud.digitalocean.com/marketplace/5ba19751fc53b8179c7a0071?i=ec3581

5. Press "Create"

6. Select the standard 8G GB Starter that is selected.

7. Choose a datacenter; I chose New York.

8. Additional options: none.

9. Add your SSH keys.

10. Choose a host name, e.g. `passivehouse-ecovillage`.

11. Select your project.

12. Press "Create"

#### Configure droplet

1. Note the IP address from above.

2. `ssh root@{ipaddress}`

3. Remove the motd (message of the day).

4. Add user:

   ```bash
   adduser username
   adduser username admin
   adduser username docker
   adduser username plugdev
   adduser username staff
   ```

5. Disable root login via SSH or via password

6. Optional: enable `username` to sudo without password.

   ```bash
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

   ```bash
   mkdir -m 700 ~username/.ssh
   cp -p .ssh/authorized_keys ~username/.ssh
   chown -R username.username ~username/.ssh/authorized_keys
   ```

9. See if you can ssh in.

10. Optional: set up `byobu` by default:

    ```bash
    byobu
    byobu-enable
    ```

11. Set the host name.

    ```bash
    vi /etc/hosts
    ```

    Change the line `127.0.1.1 name name` to `127.0.0.1 myhost.myfq.dn myhost`.

12. If needed, use `hostnamectl` to set the static hostname to match `myhost`.

13. set up Git:

    ```bash
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update
    sudo apt install git
    ```

14. We'll put the docker files at `/opt/docker/docker-ttn-dashboard`, setting up as follows:

   ```bash
   sudo mkdir /opt/docker
   cd /opt/docker
   sudo chgrp admin .
   sudo chmod g+w .
   ```

## After server is set up

The following instructions are essentially independent of the cloud provider and the underlying distribution. But we've only tested on Ubuntu and (in 2017) on CentOS.

1. Clone this repository.

   ```bash
   git clone git@github.com:mcci-catena/docker-ttn-dashboard.git /opt/docker/dashboard.example.com
   ```

2. Move to the directory populated in step 1.

   ```bash
   cd /opt/docker/dashboard.example.com
   ```

3. Get a fully-qualified domain name (FQDN) for your server, for which you control DNS. Point it to your server. Make sure it works, using "`dig FQDN`" -- you should get back an `A` record pointing to your server's IP address.

### Create and edit the `.env` file

1. Create a `.env` file. To get a template:

   ```bash
   sed -ne '/^#+++/,/^#---/p' docker-compose.yml | sed -e '/^#[^ \t]/d' -e '/^# TTN/s/$/=/' > .env
   ```

2. Edit the `.env` file as follows:

   1. `TTN_DASHBOARD_APACHE_FQDN=myhost.example.com`
   This sets the name of your resulting server. It tells Apache what it's serving out.  It must be a fully-qualified domain name (FQDN) that resolves to the IP address of the container host.

   2. `TTN_DASHBOARD_CERTBOT_FQDN=myhost.example.com`
   This should be the same as `TTN_DASHBOARD_APACHE_FQDN`.

   3. `TTN_DASHBOARD_CERTBOT_EMAIL=someone@example.com`
   This sets the contact email for Let's Encrypt. The script automatically accepts the Let's Encrypt terms of service, and this indicates who is doing the accepting.

   4. `TTN_DASHBOARD_DATA=/full/path/to/directory/`
   The trailing slash is required!
   This will put all the data file for this instance as subdirectories of the specified path. If you leave this undefined, `docker-compose` will print error messages and quit.

   5. `TTN_DASHBOARD_GRAFANA_ADMIN_PASSWORD=SomethingVerySecretIndeed`
   This sets the *initial* password for the Grafana `admin` login. You should change this via the Grafana UI after booting the server.

   6. `TTN_DASHBOARD_GRAFANA_SMTP_FROM_ADDRESS`
   This sets the Grafana originating mail address.

   7. `TTN_DASHBOARD_GRAFANA_INSTALL_PLUGINS`
   This sets a list of Grafana plugins to install.

   8. `TTN_DASHBOARD_INFLUXDB_INITIAL_DATABASE_NAME=demo`
   Change "demo" to the desired name of the initial database that will be created in InfluxDB.

   9. `TTN_DASHBOARD_MAIL_HOST_NAME=myhost.example.com`
   This sets the name of your mail server. Used by Postfix.

   10. `TTN_DASHBOARD_MAIL_DOMAIN=example.com`
   This sets the domain name of your mail server. Used by Postfix.

   11. `TTN_DASHBOARD_TIMEZONE=Europe/Paris`
   If not defined, the default timezone will be GMT.

Your `.env` file should look like this:

```bash
### env file for configuring dashboard.example.com
TTN_DASHBOARD_APACHE_FQDN=dashboard.example.com
#       The fully-qualified domain name to be served by Apache.
#
# TTN_DASHBOARD_AWS_ACCESS_KEY_ID=
# The access key for AWS for backups.
#
# TTN_DASHBOARD_AWS_DEFAULT_REGION=
# The AWS default region.
#
# TTN_DASHBOARD_AWS_S3_BUCKET_INFLUXDB=
# The S3 bucket to use for uploading the influxdb backup data.
#
# TTN_DASHBOARD_AWS_SECRET_ACCESS_KEY=
# The AWS API secret key for backing up influxdb data.
#
TTN_DASHBOARD_CERTBOT_EMAIL=somebody@example.com
#       The email address to be used for registering with Let's Encrypt.
#
TTN_DASHBOARD_CERTBOT_FQDN=dashboard.example.com
#       The domain(s) to be used by certbot when registering with Let's Encrypt.
#
TTN_DASHBOARD_DATA=/var/opt/docker/dashboard.example.com/
#       The path to the data directory. This must end with a '/', and must eithe
r
#       be absolute or must begin with './'. (If not, you'll get parse errors.)
#
TTN_DASHBOARD_GRAFANA_ADMIN_PASSWORD=...................
#       The password to be used for the admin user on first login. This is ignored
#       after the Grafana database has been built.
#
TTN_DASHBOARD_GRAFANA_PROJECT_NAME=My Dashboard
#       The project name to be used for the emails from the administrator.
#
# TTN_DASHBOARD_GRAFANA_LOG_MODE=
#       Set the grafana log mode.
#
# TTN_DASHBOARD_GRAFANA_LOG_LEVEL=
#       Set the grafana log level (e.g. debug)
#
TTN_DASHBOARD_GRAFANA_SMTP_ENABLED=true
#       Set to true to enable SMTP.
#
# TTN_DASHBOARD_GRAFANA_SMTP_SKIP_VERIFY=
#       Set to true to disable SSL verification.
#       Defaults to false.
#
# TTN_DASHBOARD_GRAFANA_INSTALL_PLUGINS=
#       A list of grafana plugins to install.
#
TTN_DASHBOARD_GRAFANA_SMTP_FROM_ADDRESS=grafana-admin@dashboard.example.com
# The "from" address for Grafana emails.
#
# TTN_DASHBOARD_GRAFANA_USERS_ALLOW_SIGN_UP=
#       Set to true to allow users to sign-up to get access to the dashboard.
#
TTN_DASHBOARD_INFLUXDB_ADMIN_PASSWORD=jadb4a4WH5za7wvp
#       The password to be used for the admin user by influxdb. Again, this is
#       ignored after the influxdb database has been built.
#
TTN_DASHBOARD_INFLUXDB_INITIAL_DATABASE_NAME=mydatabase
#       The inital database to be created on first launch of influxdb. Ignored
#       after influxdb has been launched.
#
TTN_DASHBOARD_MAIL_DOMAIN=example.com
# the postfix mail domain.
#
TTN_DASHBOARD_MAIL_HOST_NAME=dashboard.example.com
# the external FQDN for the mail host.
#
# TTN_DASHBOARD_MAIL_RELAY_IP=
# the mail relay machine, assuming that the real mailer is upstream from us.
#
# TTN_DASHBOARD_PORT_HTTP=
#       The port to listen to for HTTP. Primarily for test purposes. Defaults to
#       80.
#
# TTN_DASHBOARD_PORT_HTTPS=
#       The port to listen to for HTTPS. Primarily for test purposes. Defaults to
#       443.
#
# TTN_DASHBOARD_TIMEZONE=
#       The timezone to use. Defaults to GMT.
```

### Set up the Node-RED and InfluxDB API logins

1. Prepare everything:

    ```bash
    docker-compose pull
    ````

   If there are any errors, fix them before

2. Use `docker-compose run apache /bin/bash` to launch a shell in the Apache context.

   - If this fails with the message, `ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?`, then probably your user ID is not in the `docker` group. To fix this, `sudo adduser MYUSER docker`, where "MYUSER" is your login ID. Then (**very important**) log out and log back in.

3. Add Apache's `/etc/apache2/authdata` directory as user `www-data`.

   ```bash
   chown www-data /etc/apache2/authdata
   ```

4. Add Apache's `/etc/apache2/authdata/.htpasswd`.

   ```bash
   touch /etc/apache2/authdata/.htpasswd
   chown www-data /etc/apache2/authdata/.htpasswd
   ```

5. Add user logins for node-red and influxdb queries. Make `USERS` be a list of login IDs.

   ```bash
   export USERS="tmm amy josh"
   for USER in $USERS; do echo "Set password for "$USER; htpasswd /etc/apache2/authdata/.htpasswd $USER; done
   ```

6. Add Apache's `/etc/apache2/authdata/.htgroup`.

   ```bash
   # this assumes USERS is still set from previous step.
   touch /etc/apache2/authdata/.htgroup
   chown www-data /etc/apache2/authdata/.htgroup
   echo "node-red: ${USERS}" >>/etc/apache2/authdata/.htgroup
   echo "query: ${USERS}" >>/etc/apache2/authdata/.htgroup
   ```

7. Exit Apache's container with Control+D.

## Start the server

1. We recommend you first start things up in "interactive mode".

    ```bash
    docker-compose up
    ```

   This will show you the log files. It will also be pretty clear if there are any issues.

   One common error (for me, anyway) is entering an illegal initial InfluxDB database name. InfluxDB will spew a number of errors, but eventually it will start up anyway. But then you'll need to create a database manually.

### Restart servers in the background

Once the servers are coming up interactively, use ^C to shut them down, then restart in daemon mode.

```bash
docker-compose up -d
```

### Initial testing

- Open Grafana on **https://dashboard.example.com**, and log in as admin.

- Change the admin password.

#### Set up first data source

Use the Grafana UI -- either click on "add first data source" or use "Configure>Add Data Source", and add an InfluxDB data source.

- Set the URL (under HTTP Settings) to `http://influxdb:8086`.

- Select the database.  If InfluxDB properly initialized a database, you should also be able to connect to it as a Grafana data source. If not, you'll first need to [create an InfluxDB database](#creating-an-influxdb-database).

- Leave user and password blank.

- Click "Save & Test".

### Test Node-RED

Open Node-RED on **https://dashboard.example.com/node-red/**, and build a flow that stores data in InfluxDB. **Be sure to add the trailing slash! Otherwise you'll get a 404 from Grafana. We'll fix this soon.**

### Creating an InfluxDB database

To create a database, log in to the host machine, and cd to `/opt/docker/dashboard.example.com`. Use the following commands:

```console
$ docker-compose exec influxdb /bin/bash
# influx
Connected to http://localhost:8086 version 1.7.6
InfluxDB shell version: 1.7.6
Enter an InfluxQL query
> show databases
name: databases
name
----
_internal
> create database "my-new-database"
> show databases
name: databases
name
----
_internal
my-new-database
> ^D
# ^D
$
```

## Add Apache log in for NodeRed or query after the fact

To add a user with Node-RED access or query access, follow this procedure.

1. Log into the host machine

2. cd to `/opt/docker/dashboard.example.com`.

3. log into the apache docker container.

    ```console
    $ docker-compose exec apache /bin/bash
    #
    ```

4. In the container, move to the `authdata` directory.

    ```console
    # cd /etc/apache2/authdata
    #
    ```

5. Add the user.

    ```console
    # htpasswd .htpasswd {newuserid}
    New password:
    Re-type new password:
    Adding password for user {newuserid}
    #
    ```

6. Grant permissions to the user by updating `.htgroup` in the same directory.

    ```console
    # vi .htgroup
    ```

   There are at least two groups, `node-red` and `query`.

   - Add `{newuserid}` to group `node-red` if you want to grant access to Node-READ.

   - Add `{newuserid}` to group `query` if you want to grant access for InfluxDB queries.

7. Write and save the file, then use `cat` to display it.

8. Close the connection to apache (control+D).
