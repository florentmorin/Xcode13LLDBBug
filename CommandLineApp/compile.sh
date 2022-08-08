#!/bin/sh

if [[ -d "build" ]]; then
    rm -rf build
fi

mkdir build
mkdir build/lib

swiftc Hello.swift -g -Onone -emit-module -emit-library -static -o build/lib/libHello.a
swiftc main.swift -g -Onone -L ./build/lib/ -I ./build/lib/ -lHello -o build/app
