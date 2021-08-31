#!/bin/bash
for filename in ./*.yaml; do
    sops -d -i $filename
done