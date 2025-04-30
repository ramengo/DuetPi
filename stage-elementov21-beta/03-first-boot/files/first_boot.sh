#!/bin/bash
# Esempio di operazioni da eseguire al primo avvio
echo "Eseguo script al primo avvio... Installo plugin Duet"

# Altre operazioni di configurazione...
/opt/dsf/bin/PluginManager install /home/pi/ExecOnMcode-0.6.zip
/opt/dsf/bin/PluginManager install /home/pi/InputShaping-3.4.7.zip
/opt/dsf/bin/PluginManager install /home/pi/SpyglassWebcamServer-3.5.0.zip

# Rimuovi lo script per evitare esecuzioni future
#sudo rm /usr/local/bin/first_boot.sh
#sudo rm /etc/systemd/system/firstboot.service
#sudo systemctl daemon-reload

#sudo rm /home/pi/SpyglassWebcamServer-3.5.0.zip
#sudo rm /home/pi/InputShaping-3.4.7.zip
#sudo rm /home/pi/ExecOnMcode-0.6.zip