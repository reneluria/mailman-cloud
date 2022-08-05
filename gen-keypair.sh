#!/bin/bash

if ! [[ -e id_tf_keypair ]]; then
    ssh-keygen -t ed25519 -f id_tf_keypair -C tf-keypair -N ""
else
    echo "Key already generated"
fi
