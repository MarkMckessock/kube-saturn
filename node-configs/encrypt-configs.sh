#!/bin/bash
for filename in ./*.yaml; do
    sops -e -i $filename
done