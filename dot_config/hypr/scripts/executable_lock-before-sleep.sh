#!/usr/bin/env bash

pidof hyprlock || hyprctl dispatch exec "hyprlock --no-fade-in --grace 0"
sleep 1
