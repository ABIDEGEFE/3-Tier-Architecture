#!/bin/bash

vnetName="app_vnet"
app_subnet="appSB"
web_subnet="webSB"
resource_group="arch3"
storage_name="storage665506"
location="canadacentral"

# create resource group
az group create --name $resource_group --location $location

# create network and subnet

az network vnet create -g $resource_group \
    --name $vnetName \
    --address-prefixes 10.0.0.0/16 \
    --subnet-name $web_subnet \
    --subnet-prefixes 10.0.1.0/24

# create subnet for backend

az network vnet subnet create \
    -g $resource_group \
    --vnet-name $vnetName \
    --name $app_subnet \
    --address-prefixes 10.0.2.0/24

# create storage account to store static images

az storage account create \
    -g $resource_group \
    --name $storage_name \
    --loation $location