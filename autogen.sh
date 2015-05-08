#!/bin/bash
aclocal
autoconf
automake --add-missing
./configure --prefix="/home/iann/Github/Simple Text Editor/"
