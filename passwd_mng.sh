#!/usr/bin/zsh

# input login info
echo "パスワードマネージャーへようこそ！"
echo "サービス名を入力してください："
read service_name
echo "ユーザー名を入力してください："
read user_name
echo "パスワードを入力してください："
read user_passwd

# write login info
echo "$service_name:$user_name:$user_passwd" >> my_passwd_list.txt

echo "Thank you!"
