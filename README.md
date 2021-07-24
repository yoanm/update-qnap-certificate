# update-qnap-certificate
Simple script to update QNAP certificates (ssl and https) 

Script takes a certificate and private key filepaths and then
 - move them to a temporary directory on STunnel directory
 - copy certificate file to `/etc/stunner/backup.cert.def` and key file to `/etc/stunner/backup.key.def`
 - Generate STunnel certificate by using `/etc/init.d/stunnel.sh generate_cert_key` command
 - Restart STunnel and Qthttpd processes
 - Delete the temporary directory

# Install
Either use `git` if available or 
```bash
mkdir /share/CACHEDEV1_DATA/update-qnap-certificate
cd /share/CACHEDEV1_DATA/update-qnap-certificate
wget https://raw.githubusercontent.com/yoanm/update-qnap-certificate/master/update.sh
chmod u+x update.sh 
```
N.B.: In order to keep the directory after reboot, you have to create it on a Nas volume (System volume in above example)

# Usage
```bash
./update.sh CERT_FILEPATH KEY_FILEPATH
```

## Letsencrypt example
 - Generate your letsencrypt certificate as usual
 - Move fullchain cert and private key to a NAS shared folder (`Download` directory on following example)
 - Run the following script
```bash
./update.sh /share/Downloads/fullchain.pem /share/Download/privkey.pem
```

N.B. : Move to NAS shared folder could be managed by letsencrypt hooks

N.B.2 : `update.sh` can be launched by crontab !

Based on https://akril.net/ajouter-une-tache-cron-a-votre-nas-qnap-crontab/, in order to keep change after reboot, you have to
- Edit `/etc/config/crontab ` and add the following configuration:
  ```
  #Launched certificate replacement every minutes (in order to remove certificate files as fast as possible)
  * * * * * /share/CACHEDEV1_DATA/update-qnap-certificate/update.sh /share/Certbot/fullchain.pem /share/Certbot/privkey.pem --quiet
  ```
- Execute `crontab /etc/config/crontab` to take changes into account
- Restart crontab process : `/etc/init.d/crond.sh restart`
