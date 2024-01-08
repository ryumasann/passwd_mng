#!/usr/bin/zsh
FILE_PATH="my_passwd_list.txt"
TMP_FILE_PATH="tmp_my_passwd_list.txt"
TMP_CHANGED_PASSWD_FILE_PATH="tmp_change_my_passwd_list.txt"
OPTIONS="Add Password/Get Password/Change Password/Exit"
check_colon() {
    if [[ $1 == *:* || $2 == *:* || $3 == *:* ]]; then
        return 0
    else
        return 1
    fi
}

# ファイルにサービス名が既に存在するかチェックする関数
check_user_existance() {
    local TMP_FILE_PATH=$1
    local service_name=$2
    local user_name=$3
    local ssl_pass=$4

    while read line; do
        IFS=':' read -r file_service_name file_user_name _ <<<"$line"
        if [[ $file_service_name == $service_name ]] && [[ $file_user_name == $user_name ]]; then
            return 0
        fi
    done <$TMP_FILE_PATH
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
    echo "パスワードの暗号化、復号に使用するキーを登録してください"
    echo "※ここで入力した文字は次回以降も使用するため、必ず忘れないようにしてください"
    read -s ssl_pass
    if [ -z "$ssl_pass" ]; then
        echo "空文字は設定できません。"
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
                echo "\n空文字は設定できません。"
                continue
            fi

            # 区切り文字の使用禁止
            check_colon "$service_name" "$user_name" "$user_passwd"
            if [[ $? -eq 0 ]]; then
                echo "\n:は区切り文字と使用しているため使用不可です。"
                continue
            fi

            if [[ $file_exists == "true" ]]; then
                # サービス、ユーザー名の重複防止
                openssl enc -d -aes-256-cbc -in $FILE_PATH -out $TMP_FILE_PATH -pass pass:"$ssl_pass" 2>/dev/null
                check_user_existance "$TMP_FILE_PATH" "$service_name" "$user_name" "$ssl_pass"
                if [[ $? -eq 0 ]]; then
                    echo "\nサービス名「$service_name」にユーザー「$user_name」は既に登録されています。"
                    rm -f $TMP_FILE_PATH
                    continue
                fi
                break
            fi
            break
        done

        echo "$service_name:$user_name:$user_passwd" >>$TMP_FILE_PATH
        openssl enc -e -aes-256-cbc -in $TMP_FILE_PATH -out $FILE_PATH -pass pass:"$ssl_pass"
        echo "パスワードの追加は成功しました。"
        rm -f $TMP_FILE_PATH
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
                echo "空文字は設定できません。"
                continue
            fi
            break
        done

        openssl enc -d -aes-256-cbc -in $FILE_PATH -out $TMP_FILE_PATH -pass pass:"$ssl_pass" 2>/dev/null
        has_service_name="false"
        is_first_output="true"
        while read line; do
            IFS=':' read -r file_service_name file_user_name file_passwd <<<"$line"
            if [[ $file_service_name == $service_name ]]; then
                has_service_name="true"
                if [[ $is_first_output == "true" ]]; then
                    echo "サービス名：$file_service_name"
                    is_first_output="false"
                fi
                echo "ユーザー名：$file_user_name"
                echo "パスワード：$file_passwd"
            fi
        done <$TMP_FILE_PATH
        rm -f $TMP_FILE_PATH

        if [[ $has_service_name == "true" ]]; then
            continue
        fi
        echo "そのサービスは登録されていない、または使用したキーが間違っております。"
        echo "キーの誤りの場合は、一度処理を終了し、再度パスワードマネージャーを実行してください"
        ;;
    "Change Password")
        if [[ $file_exists == "false" ]]; then
            echo "ファイル'$FILE_PATH'が存在しません。" \
                "\n「Add Password」を入力し、パスワードリストファイルを作成してください。"
            continue
        fi

        echo "指定されたサービスのユーザーパスワードを変更します。"
        while true; do
            read "service_name?サービス名を入力してください："
            read "user_name?ユーザー名を入力してください："
            read -s "new_passwd?新しいパスワードを入力してください："
            # 空文字使用禁止
            if [ -z "$service_name" ] || [ -z "$user_name" ] || [ -z "$new_passwd" ]; then
                echo "\n空文字は設定できません。"
                continue
            fi

            # 区切り文字の使用禁止
            check_colon "$service_name" "$user_name" "$new_passwd"
            if [[ $? -eq 0 ]]; then
                echo "\n:は区切り文字と使用しているため使用不可です。"
                continue
            fi
            break
        done

        changed_flag="false"
        openssl enc -d -aes-256-cbc -in $FILE_PATH -out $TMP_FILE_PATH -pass pass:"$ssl_pass" 2>/dev/null
        while read line; do
            IFS=':' read -r file_service_name file_user_name file_passwd <<<"$line"
            if [[ $file_service_name == $service_name ]] && [[ $file_user_name == $user_name ]]; then
                echo "${line//$file_passwd/$new_passwd}" >>"$TMP_CHANGED_PASSWD_FILE_PATH"
                changed_flag="true"
            else
                echo "$line" >>"$TMP_CHANGED_PASSWD_FILE_PATH"
            fi
        done <$TMP_FILE_PATH
        if [[ $changed_flag == "true" ]]; then
            openssl enc -e -aes-256-cbc -in $TMP_CHANGED_PASSWD_FILE_PATH -out $FILE_PATH -pass pass:"$ssl_pass"
            echo "\nサービス名「$service_name」のユーザー名「$user_name」のパスワードは変更されました。"
            rm -f "$TMP_FILE_PATH" "$TMP_CHANGED_PASSWD_FILE_PATH"
        else
            echo "\nサービス「$service_name」のユーザー「$user_name」は登録されていない、または使用したキーが間違っております。"
            echo "キーの誤りの場合は、一度処理を終了し、再度パスワードマネージャーを実行してください"
            rm -f "$TMP_FILE_PATH" "$TMP_CHANGED_PASSWD_FILE_PATH"
        fi
        ;;
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
