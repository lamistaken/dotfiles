#!/bin/bash

if [[ $1 == "open" ]]; then
    hyprctl keyword monitor "eDP-1,preferred,auto,2" 
elif [[ "$( hyprctl monitors | rg Monitor | wc -l )" -gt 1 ]]; then
    hyprctl keyword monitor "eDP-1,disable" 
fi
