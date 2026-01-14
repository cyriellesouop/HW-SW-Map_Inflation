#! /bin/sh

rm -rf xsim.dir
rm -f *.log *.jou *.wdb



xvlog grayscale.v

xvlog grayscale_tb.v
xelab grayscale_tb -debug all
xsim grayscale_tb -R






