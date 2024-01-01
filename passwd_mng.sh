#!/usr/bin/zsh
FILE_PATH="my_passwd_list.txt"
OPTIONS="Add Password/Get Password/Exit"
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
    local FILE_PATH=$2
    local service_name=$3
    local ssl_key=$4

    if [[ $file_exists == "true" ]]; then
        while read line; do
            plain_pass=$(echo "$line" | openssl enc -d -des -base64 -k "$ssl_key")
            IFS=':' read -r file_service_name _ <<<"$plain_pass"
            if [[ $file_service_name == $service_name ]]; then
                return 0
            fi
        done <"$FILE_PATH"
    fi
    return 1
}

if [[ -f $FILE_PATH ]]; then
    file_exists="true"
else
    file_exists="false"
fi

echo "パスワードマネージャーへようこそ！"
# 暗号化キー入力
while true; do
    echo "パスワードの暗号化、解読に使用するキーを登録してください"
    echo "※ここで入力した文字は次回以降も使用するため、必ず忘れないようにしてください"
    read -s ssl_key
    if [ -z "$ssl_key" ]; then
        echo "空文字は設定できません。再入力してください"
        continue
    fi
    break
done

while true; do
    read "input?次の選択肢から入力してください($OPTIONS)："
    case $input in
    "Add Password")
        while true; do
            read "service_name?サービス名を入力してください："
            read "user_name?ユーザー名を入力してください："
            read -s "user_passwd?パスワードを入力してください："
            # 空文字使用禁止
            if [ -z "$service_name" ] || [ -z "$user_passwd" ] || [ -z "$user_passwd" ]; then
                echo "空文字は設定できません。再入力してください"
                continue
            fi

            # サービス名の重複防止
            check_service_existance "$file_exists" "$FILE_PATH" "$service_name" "$ssl_key"
            if [[ $? -eq 0 ]]; then
                echo "サービス名「$service_name」は既に登録されています。"
                continue
            fi

            # 区切り文字の使用禁止
            check_colon "$service_name" "$user_name" "$user_passwd"
            if [[ $? -eq 0 ]]; then
                echo ":は区切り文字と使用しているため使用不可です。"
                continue
            fi
            break
        done

        echo "$service_name:$user_name:$user_passwd" | openssl enc -e -des -base64 -k "$ssl_key" >>$FILE_PATH
        echo "パスワードの追加は成功しました。"
        # Add Passwordでファイル作成後にGet Passwordする場合のため
        file_exists="true"
        ;;
    "Get Password")
        if [[ $file_exists == "false" ]]; then
            echo "ファイル'$FILE_PATH'が存在しません。" \
                "\n「Add Password」を入力し、パスワードリストファイルを作成してください。"
            continue
        fi

        echo "指定したサービスのログイン情報を「$FILE_PATH」から取得します"
        while true; do
            read "service_name?サービス名を入力してください："
            # 空文字使用禁止
            if [ -z "$service_name" ]; then
                echo "空文字は設定できません。再入力してください"
                continue
            fi
            break
        done

        while read line; do
            plain_pass=$(echo "$line" | openssl enc -d -des -base64 -k "$ssl_key")
            IFS=':' read -r file_service_name user_name passwd <<<"$plain_pass"
            if [[ $file_service_name == $service_name ]]; then
                echo "サービス名：$service_name"
                echo "ユーザー名：$user_name"
                echo "パスワード：$passwd"
                continue 2
            fi
        done <$FILE_PATH
        echo "そのサービスは登録されていない、または使用したキーが間違っております。"
        echo "キーの誤りの場合は、一度処理を終了し、再度パスワードマネージャーを実行してください"
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
        echo "入力が間違えています。$OPTIONS から入力してください。"
        ;;
    esac
done
echo "Thank you!"
