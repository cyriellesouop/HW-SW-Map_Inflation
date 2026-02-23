#!/bin/sh

#gcc inflation_no_print.c -o inflation -lm

#gcc -O2 inflation_timer.c -o inflation -lm 

#gcc -O2 inflation_sliding_timer_200.c -o inflation -lm 

#gcc  inflation_sliding_timer_200.c -o inflation -lm 

#gcc  inflation_sliding_timer_50.c -o inflation -lm 

gcc  inflation_sliding_timer_1000.c -o inflation -lm 


./inflation
