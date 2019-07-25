#!/bin/bash
# This script starts Kepler.
export HOME=/home/`whoami` # Run with -h to see all command-line options.
export KEPLER=/opt/kepler/kepler-2.4 #auto-generated

CUR_DIR=`pwd`
SCRIPT_DIR=`dirname $BASH_SOURCE`
cd $SCRIPT_DIR

#fix later
xhost +
java -classpath build-area/lib/ant.jar:kepler.jar org.kepler.build.runner.Kepler -Drifcs.host=oaipmh2.coesra.org.au -Dsite.host=oaipmh2.coesra.org.au "$@"
cd $CUR_DIR

