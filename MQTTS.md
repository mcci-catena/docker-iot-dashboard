# MQTTS Tips

MQTTS is outside the scope of this project. 

Here are some notes:

Example Publish:

> `mosquitto_pub -d --url mqtts://everynet-iot-dash:Pa$$W0rd@surveyor.example.com:8883/himom -m "welcome to 2023"`

```
Usage: mosquitto_pub {[-h host] [--unix path] [-p port] [-u username] [-P password] -t topic | -L URL}
                     {-f file | -l | -n | -m message}
                     [-c] [-k keepalive] [-q qos] [-r] [--repeat N] [--repeat-delay time] [-x session-expiry]
                     [-A bind_address] [--nodelay]
                     [-i id] [-I id_prefix]
                     [-d] [--quiet]
                     [-M max_inflight]
                     [-u username [-P password]]
                     [--will-topic [--will-payload payload] [--will-qos qos] [--will-retain]]
                     [{--cafile file | --capath dir} [--cert file] [--key file]
                       [--ciphers ciphers] [--insecure]
                       [--tls-alpn protocol]
                       [--tls-engine engine] [--keyform keyform] [--tls-engine-kpass-sha1]]
                       [--tls-use-os-certs]
                     [--psk hex-key --psk-identity identity [--ciphers ciphers]]
                     [--proxy socks-url]
                     [--property command identifier value]
                     [-D command identifier value]
       mosquitto_pub --help
```

## Mosquitto on MacOS

Testing from the Mac can help. Get the client.

`brew install mosquitto`

```
mosquitto has been installed with a default configuration file.
You can make changes to the configuration by editing:
    /usr/local/etc/mosquitto/mosquitto.conf

To restart mosquitto after an upgrade:
  brew services restart mosquitto
Or, if you don't want/need a background service you can just run:
  /usr/local/opt/mosquitto/sbin/mosquitto -c /usr/local/etc/mosquitto/mosquitto.conf
```

## Check the Certificate
Use this command to check the certificate

openssl s_client -servername broker.mydomain.com -connect broker.mydomain.com:8883 2> dev/null | openssl x509 -noout -dates