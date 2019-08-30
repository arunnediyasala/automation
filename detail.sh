#!/bin/bash
sudo mv /home/ubuntu/slurm.conf /etc/slurm-llnl/.
if [ $1 -eq 0 ]; then
	sudo systemctl start slurmd
	sleep 1
	sudo systemctl start slurmctld

else
	sudo systemctl start slurmd
fi
What="fs-9c3b7d7f.efs.us-east-1.amazonaws.com"
Where=/data-efs
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $What:/ $Where
