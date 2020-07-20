#!/bin/sh
. zospmsetenv 

zospmdeploy "$1" zospm-igybin.bom
exit $? 
