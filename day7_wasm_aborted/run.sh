#!/bin/bash
set -xe

clj -M part1.clj > temp.wat
wasmtime temp.wat

