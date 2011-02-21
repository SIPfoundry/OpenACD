#!/bin/sh

cp proto_src/* src/
if [ ! -d ebin ]; then
	mkdir ebin
fi

if [ "${GIT_UPDATE_DISABLED}" != "1" ]; then
	echo "Updating submodules..."
	git submodule init && git submodule update
fi

# hack for reltool
if [ ! -d OpenACD ]; then
	mkdir OpenACD
	ln -sf ../ebin OpenACD/ebin
	ln -sf ../src OpenACD/src
	ln -sf ../include OpenACD/include
	ln -sf ../priv OpenACD/priv
	ln -sf ../deps OpenACD/deps
fi
