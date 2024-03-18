#!/bin/bash

# 定义原始字符串
string="dir///////folder////////aaaaaaa"

# 使用 sed 命令替换连续多个斜杠为单个斜杠
result=$(echo "$string" | sed 's/\/\+/\//g')

# 输出结果
echo "$result"
