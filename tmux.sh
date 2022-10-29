#!/bin/bash
session=harvest

tmux new -d -s $session
tmux send-keys -t $session 'vim' C-m
tmux new-window -t $session
tmux new-window -t $session
tmux a
