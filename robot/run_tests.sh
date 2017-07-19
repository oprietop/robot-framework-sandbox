#!/bin/sh
for i in *robot; do
    robot -P resource -d ${i}_DIR $i
done
