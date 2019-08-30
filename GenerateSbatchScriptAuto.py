#!/usr/bin/env python
# Single argument: name of <test>.yml

import yaml
import sys
import subprocess
import os.path

if len(sys.argv) < 4:
    exit(0)

testSuiteName = sys.argv[1]
testToRun = sys.argv[2] #default is all
valgrind = sys.argv[3]=="True"
numberofNode = sys.argv[4]
with open("./tests/" + testSuiteName +".yml", 'r') as stream:
    try:
        testSuite=yaml.safe_load(stream)

        # iterate over test suite and build run command
        if testToRun !="all":
	        totalNum = 1
        else:
                totalNum = len(testSuite)
        print("""#!/bin/bash

#SBATCH -N {} # 1 nodes
#SBATCH -c 1 # 1 core per task""".format(numberofNode))

        print("#SBATCH -n", totalNum)
#SBATCH -c 1 # 1 core per task
        for i in range(totalNum):

            test = testSuite[i]

            # get name of test
            testName = next(iter(test.keys()))

            if testToRun!="all" and testToRun!=testName:
                continue

            #get dictionary with test properties
            testProperties = test[testName]
            workloadName = testProperties["workload"]

            testProperties["params"]["perfFileName"] = "./logs/" + testSuiteName + "/" + testName

            #generate log directories
            subprocess.call(["mkdir","-p","./logs/" + testSuiteName + "/"])
            subprocess.call(["rm","-f",testProperties["params"]["perfFileName"]])
            subprocess.call(["mkdir","-p","./stdlog/" + testSuiteName + "/"])

  
            cmd = ["LD_LIBRARY_PATH=./build/lib", "srun", "-N 1 -n 1 --output=./stdlog/{}/{}".format(testSuiteName,testName)]
            #cmd = ["LD_LIBRARY_PATH=./build/lib ", "srun"]

            #build command
            cmd.append("./build/workloads/"+workloadName +"/" +workloadName)

            #turn properties into command line parameters
            for param in testProperties["params"]:
                cmd.append("--"+param+"="+str(testProperties["params"][param]))

            #cmd.append("\"")

            # for slurmParam in testProperties["slurmParams"]:
            #     cmd.append("--"+slurmParam+"="+str(testProperties["slurmParams"][slurmParam]))

            if valgrind:
                cmd = ["LD_LIBRARY_PATH=./build/lib","valgrind", "--vgdb=yes", "--vgdb-error=0", cmd[0]]

            if valgrind:
                print(" ".join(cmd))
                exit(0)
            if i < totalNum - 1:
                print(" ".join(cmd)+" & ")
            else:
                print(" ".join(cmd)+"\nwait")
    except yaml.YAMLError as exc:
        print(exc)
