#!/bin/bash
container_name=$1
tag=$(git name-rev --name-only --tags HEAD)
if [[ $tag != "undefined" ]]; then
	latest_tag=$(git describe --abbrev=0)
	# make sure to build on the latest tag
	git checkout $(latest_tag)
	/bin/bash .travis/build.sh -u "coesra/$container_name" -c registry "Singularity.$container_name" 
else
	echo "Not in tag. Not build attempted!"
fi

