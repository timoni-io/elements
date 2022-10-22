#!/bin/bash

SOURCEDIR=$INIT_DATA_SOURCEDIR

DESTDIR=$INIT_DATA_DESTDIR

ERROR=""
DESTFULL=""

if [ -z "$INIT_DATA_SOURCEDIR" ] ; then
        ERROR+="Environment variable INIT_DATA_SOURCEDIR not set. "
fi

if [ -z "$INIT_DATA_DESTDIR" ] ; then
        ERROR+="Environment variable INIT_DATA_DESTDIR not set. "
fi

if [ ! -d $SOURCEDIR ]; then
        ERROR+="No source directory $SOURCEDIR. "
fi

if [ ! "$(ls -A $SOURCEDIR)" ]; then
        ERROR+="Source directory $SOURCEDIR was empty. Nothing to copy. "
fi

if [ ! -d $DESTDIR ]; then
        ERROR+="No destination directory $DESTDIR. "
fi

if [ "$(ls -A $DESTDIR)" ]; then
        DESTFULL+="Destination directory $DESTDIR was not empty. "
fi


if [ -z "$ERROR" ] && [ -z "$DESTFULL" ]; then
        cp $SOURCEDIR/* $DESTDIR
        DESTFULL+="Data from $SOURCEDIR was copied to $DESTDIR"
        echo $DESTFULL
else

if [ -z "$ERROR" ] && [ ! -z "$DESTFULL" ]; then
        cd /app 
        ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
        exec dotnet Nop.Web.dll
fi
