#!/bin/bash
# empty prerun to satisfy pi-gen
#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	copy_previous
fi
