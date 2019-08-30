# Ns3 testing
Running Ns3 program using slurm cluster. We can able to run single program or multipple programs using different aws instance.

## Getting Started

We have a deployer server that is mounted with efs (/data-efs) storage.It is consiting of all the Ns3 automation script. My recommendation is to use the server to deploy the job. 

### Prerequisites

Provide your ssh public key to the administrator so he will allow you to access to the server. Next step is to create a folder with unique name then you need to clone your ns3 code in to that folder. The cloned folder should have a test script in the form of yamil and located in the tests folder.If not create one and save to the tests folder as a yml file. In your local machine you have to add the key to the ssh. 

```
ssh-add YOURKEY.pem

```
Add your aws key to the main.tf file with variable called key_name.
Also change the permission of the newly created folder 
```
sudo chown ubuntu:ubuntu -R <new-folder-name>

```

### Installing

If you wan to see which instance you are going to use and how many cores are present, these infromation are in the main.tf file. In that you can see the instance_type, cpu_core_count, and the aws credentials used to login.


If you want to edit the aws credentials then you can edit the main.tf. Possible changes are the instance_type, key_name, cpu_core_count etc.Next we are going to see deploy.sh, which is basically launching the instance and extracting the details about the launched instance. Then copying the slurm credentials to the launched instance.

details.sh which is basically running on the remote instance to attach the efs to newly created instance.

finally there is a jobToRun, which is used for starting slurm test for the given job


## Running the tests
To run the test use the following format
```
./deploy.sh <fileName> <jobID> <number_of_instance> <jobName>  <test_name>
for example 
./deploy.sh slurmtest scalauser1 2 fb-sim-baseline3 all
```
slurmtest is the ns3 codebase name, scalauser1 is the jobID, 2 is the number of instance needed to run the test, fb-sim-baseline3 which is the test script in the form of yamil finally you have test_name which is the either "all" or you can specify which test you want to run, for example CT_Q_50 etc..


### Break down into end to end tests


There are two main programs  are there fb-sim and fb-multihost. Then there are two diffrent standard test such as baseline1 and baseline3. baseline1 is a quick test of 6 diffrent jobs and baseline3 is the full test consisting of all 19 jobs.

```
fb-sim-base1.yml for baseline1 test
fb-sim-base3.yml for baseline3 test
modular-baseline1.yml for modular baseline1 test
modular-baseline3.yml for modular baseline3 test
fb-sim-mh.yml for multihost test
modular_mh_00.yml for modular multihost test
```

### And coding style tests

The baseline1 and baseline3 test is different in runtime if you want to test your program better test with baseline1 then you check your result if the result is acceptable then go for baseline3. For example fb-sim-base1.yml take less than an hour to finish the test. if you are using baseline3 test for the fb-sim-base3 then it takes 72 hours to finish all 19 test on the z1d.12x large instance. The same scenario for the modular-fb-sim code.


## Deployment

Use the server to run the test

## Simulation status

If we want to know the simulation status then we have a script called the simStatus.sh which will look the stdlog file and it will produce the simulation status.

```./simStatus.sh <testname>
```

### Post processing

Once the simulation is finished then we have a Postprocess script that will convert the result into metric format, such as mean, p50,p99,p99.9.The post processing script will generate the output in html format. The postprocessing folder is located in the /data-efs ( which is mounted to the server) folder name is postprocessing

```
./postProcess.sh <expectedfile_folder_name> <actualfiles_folder_name> 
./postProcess.sh pathto/fb-sim-base3  pathto/fb-modular-base3
```
We are compairing the reuslt of original code with the modularized code and if the result is more than 10 percentage then it is highlated that column.
The result will be present in the folder named CSVtoHTML and the file name is NS3analysis.html

### Terminating the job and instance
To terminate job we need to login to any one launched cluster instance and type the following command to know the status of the job
```
sinfo
```
sinfo shows the status of the slurm.
```
squeue
```
squeue shows the status of the running job especially how long the job was running and how many instance is utilised for running the job
```
scancel <slurm-job-number>
```
scancel is used to cancel the running job

If you dont want to run the job in the launched instance and you really want to terminate the instance then we can use the script named destroy.sh that will terminate the launched instances.

```
./destroy <jobID>
```


jobID we have used for launching the instances, the same we can able to use to destroy the instance.


## Built With

* [Terraform](https://www.terraform.io/) - The infrastructure software
* [aws](https://aws.amazon.com/) - Cloud platform
* [ns3](https://www.nsnam.org/) - Ns3 software
* [slurm](https://slurm.schedmd.com/documentation.html) - for HPC platform


 



