#!/bin/bash
eksctl create cluster --name spogaku --version 1.22 --region ap-southeast-1 --nodegroup-name standard-workers --node-type t2.small --nodes 3 --nodes-min 3 --nodes-max 3
