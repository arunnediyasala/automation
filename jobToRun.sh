#!/bin/bash
fileName=$1
jobName=$2
testName=$3
numberOfInstance=$4
cp GenerateSbatchScriptAuto.py StartSlurmAuto.sh jobToRun.sh /data-efs/$fileName/super-secret-2/.
cd /data-efs/$fileName/super-secret-2
./compile.sh
./StartSlurmAuto.sh $jobName $testName f $numberOfInstance
