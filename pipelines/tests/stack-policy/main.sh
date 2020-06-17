#!/bin/bash

yum -y install findutils

# Time to run tests now
scriptHome=$(dirname $(readlink -f $0))
level=$(date "+%Y-%m-%d_%H%M%S")
buildPath=$scriptHome/build_${level}
# cd $scriptHome/tests

mkdir -p $buildPath
ln -fsvn $buildPath $scriptHome/build

let anyfail=0
failed=""

# find any .sh|test.yaml|test.yml
regressionTestScripts=$(find . -type f -name '*.sh'| sort)
for testcase in $( echo "$regressionTestScripts") ; do
   if [ -f "$testcase" ] ; then
     testsuiteName=$(basename $(dirname $testcase))
     testcaseScript=$(basename "$testcase")
     testcaseName=${testcaseScript%.*}
     testcasePath=$buildPath/$testsuiteName/$testcaseName
     outputPath=$testcasePath/output
     resultsPath=$testcasePath/results
     mkdir -p $outputPath
     mkdir -p $resultsPath
     echo "*** Running testcase $testcase"
     cd $(dirname "$testcase") 
     if [[ $testcase == *.sh ]] ; then
       ./$testcaseScript > >(tee -a $resultsPath/${testcaseScript}.stdout.txt) 2> >(tee -a $resultsPath/${testcaseScript}.stderr.txt >&2)
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
         touch $testcasePath/FAILED.TXT
       else
         touch $testcasePath/PASSED.TXT
       fi

     fi
     if [[ $testcase == *.yaml ]] || [[ $testcase == *.yml ]] ; then
       ansible-playbook $testcaseScript  > >(tee -a $resultsPath/${testcaseScript}.stdout.txt) 2> >(tee -a $resultsPath/${testcaseScript}.stderr.txt >&2)
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
         touch $testcasePath/FAILED.TXT
       else
         touch $testcasePath/PASSED.TXT
       fi
     fi
     cd -
   else
     echo "*** No test found in $testcase"
   fi
done

# Summarize results
if [ $anyfail -eq 0 ] ; then
   echo "*** All testcases ran without error"
else
   echo "*** There were $anyfail testcase failures - $failed"
fi 

# get the logs
cd $buildPath
$scriptHome/scripts/kabanero-mustgather.sh

exit $anyfail