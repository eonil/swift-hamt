#!/bin/env zsh

rm -rf .build build
swift package clean
swift build
swift test

