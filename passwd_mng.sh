#!/usr/bin/zsh
file_path="my_passwd_list.txt"
check_colon() {
    if [[ $1 == *:* || $2 == *:* || $3 == *:* ]]; then
        return 0
    else
        return 1
    fi
}

# ファイルにサービス名が既に存在するかチェックする関数
check_service_existance() {
    local file_exists=$1
    local file_path=$2
    local service_name=$3

    if [[ $file_exists == "true" ]]; then
        while IFS=: read -r file_service_name _; do
            if [[ "$file_service_name" == "$service_name" ]]; then
                return 0
            fi
        done <"$file_path"
    fi
    return 1
}

if [[ -f $file_path ]]; then
    file_exists="true"
else
    file_exists="false"
fi

echo "パスワードマネージャーへようこそ！"
while true; do
    read "input?次の選択肢から入力してください(Add Password/Get Password/Exit)："
    case $input in
    "Add Password")
        read "service_name?サービス名を入力してください："
        # サービス名の重複防止
        check_service_existance "$file_exists" "$file_path" "$service_name"
        if [[ $? -eq 0 ]]; then
            echo "サービス名「$service_name」は既に登録されています。"
            continue
        fi

        read "user_name?ユーザー名を入力してください："
        read "user_passwd?パスワードを入力してください："

        # 区切り文字の使用禁止
        check_colon "$service_name" "$user_name" "$user_passwd"
        if [[ $? -eq 0 ]]; then
            echo ":は区切り文字と使用しているため使用不可です。"
            continue
        fi
        # 空文字使用禁止
        # TODO
        echo "$service_name:$user_name:$user_passwd" >>$file_path
        echo "/nパスワードの追加は成功しました。"
        # Add Passwordでファイル作成後にGet Passwordする場合のため
        file_exists="true"
        ;;
    "Get Password")
        if [[ $file_exists == "false" ]]; then
            echo "ファイル'$file_path'が存在しません。" \
                "\n「Add Password」を入力し、パスワードリストファイルを作成してください。"
            continue
        fi

        echo "指定したサービスのログイン情報を「$file_path」から取得します"
        read "service_name?サービス名を入力してください："
        while IFS=: read -r file_service_name user_name passwd; do
            if [[ $file_service_name == $service_name ]]; then
                echo "サービス名：$service_name"
                echo "ユーザー名：$user_name"
                echo "パスワード：$passwd"
                continue 2
            fi
        done <$file_path
        echo "そのサービスは登録されていません。"
        ;;
    # "Change Password")
    #   TODO
    #     continue
    #     ;;
    "Exit")
        echo "処理を終了します"
        break
        ;;
    *)
        echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
        ;;
    esac
done
echo "Thank you!"
