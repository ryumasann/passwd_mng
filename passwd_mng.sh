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
    local ssl_key=$4

    if [[ $file_exists == "true" ]]; then
        while read line; do
            plain_pass=$(echo "$line" | openssl enc -d -des -base64 -k "$ssl_key")
            plain_pass_space_separated=${plain_pass//:/ }
            plain_pass_list=($plain_pass_space_separated)
            if [[ $plain_pass_list[0] == $service_name ]]; then
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
echo "パスワードマネージャーを使用するのは初めてですか？(y/n)"
while true; do
    # 暗号化キー入力
    read answer
    if [[ $answer == "y" ]]; then
        echo "パスワードの暗号化、解読に使用するキーを登録してください"
        echo "※ここで入力した文字は次回以降も使用するため、必ず忘れないようにしてください"
        while true; do
            read ssl_key
            if [ -z "$ssl_key" ]; then
                echo "空文字は設定できません。再入力してください"
                continue
            fi
            break 2
        done
    elif [[ $answer == "n" ]]; then
        echo "前回登録したパスワードの暗号化、解読に使用するキーを入力してください"
        while true; do
            read ssl_key
            if [ -z "$ssl_key" ]; then
                echo "空文字は設定できません。再入力してください"
                continue
            fi
            break 2
        done
    else
        echo "yまたはnで入力してください"
        continue
    fi
done

while true; do
    read "input?次の選択肢から入力してください(Add Password/Get Password/Exit)："
    case $input in
    "Add Password")
        while true; do
            read "service_name?サービス名を入力してください："
            # 空文字使用禁止
            if [ -z "$service_name" ]; then
                echo "空文字は設定できません。再入力してください"
                continue
            fi
            break
        done

        # サービス名の重複防止
        check_service_existance "$file_exists" "$file_path" "$service_name" "$ssl_key"
        if [[ $? -eq 0 ]]; then
            echo "サービス名「$service_name」は既に登録されています。"
            continue
        fi

        # 空文字使用禁止
        while true; do
            read "user_name?ユーザー名を入力してください："
            read "user_passwd?パスワードを入力してください："
            if [ -z "$user_name" ] || [ -z "$user_passwd" ]; then
                echo "空文字は設定できません。再入力してください"
                continue
            fi
            break
        done

        # 区切り文字の使用禁止
        check_colon "$service_name" "$user_name" "$user_passwd"
        if [[ $? -eq 0 ]]; then
            echo ":は区切り文字と使用しているため使用不可です。"
            continue
        fi
        echo "$service_name:$user_name:$user_passwd" | openssl enc -e -des -base64 -k "$ssl_key" >>$file_path
        echo "パスワードの追加は成功しました。"
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
        done <$file_path
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
        echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
        ;;
    esac
done
echo "Thank you!"
