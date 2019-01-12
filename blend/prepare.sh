#!/bin/sh
for k in *.dae; do
	sed -e 's@file://@@g' -i $k
done

