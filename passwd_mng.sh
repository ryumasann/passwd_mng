# !/usr/bin/zsh
faile_path="my_passwd_list.txt"

echo "パスワードマネージャーへようこそ！"
while true; do
    read "input?次の選択肢から入力してください(Add Password/Get Password/Exit)："
    case $input in
    "Add Password")
        read "service_name?サービス名を入力してください："
        read "user_name?ユーザー名を入力してください："
        read "user_passwd?パスワードを入力してください："
        echo "$service_name:$user_name:$user_passwd" >>$faile_path
        echo "\nパスワードの追加は成功しました。"
        ;;
    "Get Password")
        echo "指定したサービスのログイン情報を「$faile_path」から取得します"
        read "service_name?サービス名を入力してください："
        login_info=$(grep ^${service_name}: $faile_path)
        if [ -z $login_info ]; then
            echo "そのサービスは登録されていません。"
            continue
        fi
        IFS=':'
        read -r service_name user_name passwd <<<$login_info
        echo "サービス名：$service_name"
        echo "ユーザー名：$user_name"
        echo "パスワード：$passwd"
        ;;
    "Exit")
        echo "処理を終了します"
        break
        ;;
    *)
        echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
        continue
        ;;
    esac
done
echo "Thank you!"
