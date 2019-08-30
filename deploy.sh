#!/bin/bash
#### converting IP address to the slurm LogTimeFormat
fileName=$1
jobID=$2
numberOfInstance=$3
jobName=$4
testName=$5
stateName=$jobID.json
echo " state name for the terrafrom $stateName"
if [ $# -lt 4 ]
   then
	echo "########### Input argument is not sufficent to run the test ###########"
        echo " format is ./deploy.sh <fileName> <jobID> <number_of_instance> <jobName>  <test_name>"
        echo "for example ./deploy.sh slurmtest arun01 2 fb-sim-baseline3 all "
	exit 1
fi
terraform init
terraform apply -auto-approve -state=$stateName -var "instcount=$numberOfInstance" -var "tagName=$jobID"
counter=0
#sudo chown ubuntu:ubuntu -R /data-efs/$fileName
while [ $counter -lt $numberOfInstance ]; do
    private_ip_[$counter]=`jq .outputs.private_compute.value[$counter] $stateName`
    let counter=counter+1
done
for i in ${private_ip_[@]};do
	echo "private IP"$i
done

###### converting slurm.conf
tmp=${private_ip_[0]}
headhost=`echo $tmp | sed -e 's/^"//' -e 's/"$//' | sed -r 's/[.]+/-/g'`
headhost="ControlMachine=ip-$headhost"
tmp=`echo $tmp | sed -e 's/^"//' -e 's/"$//'`
tmp="ControlAddr=$tmp"
echo $headhost
sed -i  "/ControlMachine/c${headhost}" "slurm.conf"
sed -i  "/ControlAddr/c${tmp}" "slurm.conf"
counter=0
sed -i '/NodeName=scala/d' slurm.conf
sed -i '/PartitionName/d' slurm.conf
for i in ${private_ip_[@]};do
        nodeaddr=`echo $i | sed -e 's/^"//' -e 's/"$//'`
	nodeaddr="NodeAddr=$nodeaddr"
	nodename=`echo $i | sed -e 's/^"//' -e 's/"$//' | sed -r 's/[.]+/-/g'`
        nodename="NodeHostname=ip-$nodename"
        sc="NodeName=scala${counter} ${nodeaddr} ${nodename} CPUs=4 Procs=1 State=UNKNOWN"
        echo $sc >> slurm.conf
	let counter=counter+1
done
let totalinstance=$numberOfInstance-1
sc1="PartitionName=debug Nodes=scala[0-$totalinstance] MaxTime=INFINITE Default=YES State=UP"
echo $sc1 >> slurm.conf
while true
do 
   echo "Hit any key to continue"
   read x
   break;
done
sleep 30
counter=0
for i in ${private_ip_[@]};do
        i=`echo $i | sed -e 's/^"//' -e 's/"$//'`
	scp -o "ForwardAgent yes" slurm.conf detail.sh simStatus.sh GenerateSbatchScriptAuto.py StartSlurmAuto.sh ubuntu@$i:/home/ubuntu/. 
	ssh -A ubuntu@$i ./detail.sh $counter
	let counter=counter+1
done

ip=${private_ip_[0]}
ip=`echo $ip | sed -e 's/^"//' -e 's/"$//'`

ssh -A ubuntu@$ip << EOF
sudo scontrol
update NodeName=scala[0-$totalinstance] State=RESUME
exit
EOF
scp -o "ForwardAgent yes" jobToRun.sh ubuntu@$ip:/home/ubuntu/.
ssh -A ubuntu@$ip ./jobToRun.sh $fileName $jobName $testName $numberOfInstance

