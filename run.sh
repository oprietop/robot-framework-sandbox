#!/usr/bin/sh

BIN="docker-compose telnet vncviewer"
echo "Verificando binarios $BIN:"
which $BIN || { echo "Faltan binarios!";  exit 1;}

echo "# Executing compose"
docker-compose down
docker-compose pull
docker-compose up -d

while true; do
    echo "# Waiting for the VNC Server to become ready ..."
    sleep 3 | telnet 127.0.0.1 5900 | grep -q RFB && break
done

echo "# Launching vncviewer, menu is on the F8 key."
vncviewer localhost:5900 -passwd vnc/passwd &

echo "# Running worker, workdir is in /robot"
docker-compose run worker sh

echo "# Exiting..."
docker-compose down
