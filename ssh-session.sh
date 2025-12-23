#!/bin/bash
# 创建一个 tmux session，所有新 window/pane 自动 ssh 到指定服务器

if [ -z "$1" ]; then
    echo "用法: $0 <服务器地址> [session名]"
    echo "示例: $0 user@192.168.1.100 myserver"
    exit 1
fi

SERVER="$1"
SESSION_NAME="${2:-ssh-$SERVER}"

# 检查 session 是否已存在
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' 已存在，正在切换..."
    tmux switch-client -t "$SESSION_NAME"
    exit 0
fi

# 创建新 session（detached），设置 hooks
tmux new-session -d -s "$SESSION_NAME" -n "ssh" "ssh $SERVER" \;\
    set-option -t "$SESSION_NAME" default-command "ssh $SERVER" \;\
    set-hook -t "$SESSION_NAME" after-new-window "send-keys 'ssh $SERVER' Enter" \;\
    set-hook -t "$SESSION_NAME" pane-created "send-keys 'ssh $SERVER' Enter" \;\
    switch-client -t "$SESSION_NAME"

echo "Session '$SESSION_NAME' 已创建，所有新 window/pane 将自动 ssh 到 $SERVER"
