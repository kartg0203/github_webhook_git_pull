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

# Check if git command is available
if ! command -v git &> /dev/null; then
    echo "$(date +"%Y-%m-%dT%H%M%SZ") Git command not found. Stopping the execution." >> /var/log/gitPull.log
    exit 1
fi

# 不是 main branch 就退出
if [ $(echo $branch_name | grep -c main) -eq 0 ]; then
    exit 1
fi

repository_path="/app/repositories/${repository_name}"

cd $repository_path || exit

# Execute git pull
if ! git pull origin $branch_name; then
    echo "$(date +"%Y-%m-%dT%H%M%SZ") Git Pull failed for repository ${repository_name}, branch ${branch_name}, git code $?" >> /var/log/gitPull.log
    exit 1
fi

# log
echo "$(date +"%Y-%m-%dT%H%M%SZ") Git Pull completed for repository ${repository_name}, branch ${branch_name}" >> /var/log/gitPull.log

exit 0
