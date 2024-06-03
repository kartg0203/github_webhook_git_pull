#!/bin/sh

# Receive command-line arguments
repository_name=$1
branch_name=$2

if [ -z $repository_name ]; then
    echo "$(date +"%Y-%m-%dT%H%M%SZ") Fetching 'repository.name' from JSON payload failed. Stopping the execution." >> /var/log/gitPull.log
    exit 1
fi

if [ -z $branch_name ]; then
    echo "$(date +"%Y-%m-%dT%H%M%SZ") Fetching 'ref' from JSON payload failed. Stopping the execution." >> /var/log/gitPull.log
    exit 1
fi

# 不是 main branch 就退出
if [ $(echo $branch_name | grep -c main) -eq 0 ]; then
    echo "$(date +"%Y-%m-%dT%H%M%SZ") Branch is not main. Stopping the execution." >> /var/log/gitPull.log
    exit 1
fi
echo "repository_name: ${repository_name}" >> /var/log/gitPull.log
exit 1
repo_path="/app/repositories/${repository_name}"

cd $repo_path || exit

# 執行git pull
git pull "{$branch_name}"

# log
echo "$(date +"%Y-%m-%dT%H%M%SZ") Git Pull completed for repository ${repo_name}, branch ${branch_name}" >> /var/log/gitPull.log

exit 0
