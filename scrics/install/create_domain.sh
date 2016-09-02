#!/bin/bash
v_actual_dir=`pwd`
fichero_ini=$1
source $2

cd $v_actual_dir

java weblogic.WLST create_domain.py $fichero_ini
