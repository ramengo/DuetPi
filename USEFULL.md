### Cleaning target is busy after fail build

sudo umount -l  /path/dev ecc


### Command to run on realpath: /home/pi/Desktop/DuetPi/work/3DforMe/stage-3dforme/rootfs/sys: No such file or directory

sudo find ./ -name "*.sh" -exec chmod a+x {} \;


realpath docker problem
find ./ -name "*.sh" -exec chmod a+x {} \;


sudo PRESERVE_CONTAINER=1 ./build-docker.sh -c config_tc
sudo CONTINUE=1 ./build-docker.sh -c config_tc

sudo CONTAINER_NAME=FABBRIX_TC PRESERVE_CONTAINER=1 ./build-docker.sh -c config_tc

docker rm -v pigen_work

sudo docker run -it --privileged --volumes-from=pigen_work pi-gen /bin/bash


touch ./stage0/SKIP ./stage1/SKIP ./stage2/SKIP ./stage-dsf/SKIP ./stage3/SKIP ./stage4/SKIP ./stage-dsf-gui/SKIP ./stage-nodered/SKIP

rm ./stage0/SKIP ./stage1/SKIP ./stage2/SKIP ./stage-dsf/SKIP ./stage3/SKIP ./stage4/SKIP ./stage-dsf-gui/SKIP ./stage-nodered/SKIP



on_chroot << EOF
	mkdir -p ~/mjpg-streamer
	cd ~/mjpg-streamer
	git clone https://github.com/jacksonliam/mjpg-streamer.git
	cd mjpg-streamer/mjpg-streamer-experimental
	make
	make install
EOF



sudo PRESERVE_CONTAINER=1 ./build-docker.sh -c config_um
docker run -it --rm --privileged \
                --volumes-from="${CONTAINER_NAME}" --name "${CONTAINER_NAME}_cont" \
                -e IMG_NAME=${IMG_NAME} \
                pi-gen \
                bash