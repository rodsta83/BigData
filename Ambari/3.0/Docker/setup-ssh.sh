#!/bin/bash

# Setup SSH for all containers
docker exec -i bigtop_hostname0 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF


docker exec -i bigtop_hostname1 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF

docker exec -i bigtop_hostname2 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF

docker exec -i bigtop_hostname3 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF