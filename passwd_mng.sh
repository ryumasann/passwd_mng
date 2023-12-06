#!/usr/bin/zsh
faile_path="my_passwd_list.txt"

echo "パスワードマネージャーへようこそ！"
while true; do
    read "input?次の選択肢から入力してください(Add Password/Get Password/Exit)："
    case $input in
        "Add Password")
            echo "サービスごとのログイン情報を「$faile_path」に追加します。"
	    read "service_name?サービス名を入力してください："
	    read "user_name?ユーザー名を入力してください："
	    read "user_passwd?パスワードを入力してください："
	    echo "$service_name:$user_name:$user_passwd" >> $faile_path
	    ;;
        "Exit")
            echo "処理を終了します"
            break
            ;;
        *)
            echo "不正な値です。"
            continue
            ;;
    esac
done
echo "Thank you!"
