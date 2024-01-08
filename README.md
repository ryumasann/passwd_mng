# パスワードマネージャー
パスワードを管理するシェルスクリプトです。

様々なサービスで使用するIDとパスワードを安全に管理するためのツールです。

## 仕様
当該ツールでは以下３つの処理が可能です。
- パスワードの保存
- パスワードの参照
- パスワードの変更

シェルスクリプトを実行すると、最初に以下が表示されます。

```bash
パスワードマネージャーへようこそ！
パスワードの暗号化、復号に使用するキーを登録してください
※ここで入力した文字は次回以降も使用するため、必ず忘れないようにしてください
次の選択肢から入力してください(Add Password/Get Password/Change Password/Exit)：
```

パスワードの保存する際の暗号化や参照の際に使用するキーは、今後このツールを使用する際に同一のものを使用して頂く必要があるため、
忘れないようにして頂く必要があります。
また、複数のキーを使用することはできません。

処理全体を通しての補足としては、パスワード情報に空文字を使用することは想定されていないため、
空文字を使用した場合は再度入力を促すようにしております。


それぞれの選択肢を選んだ場合の機能の仕様について、以下に詳細を記載いたします。

### パスワードの保存(Add Passwordを入力した場合)
以下の情報をopensslを使用して暗号化された状態でファイル「my_passwd_list.txt」として、当該ツールが有るディレクトリにに保存します。
- サービス名
- ユーザー名
- パスワード

```bash
# Add Password が入力された場合
サービス名を入力してください：
ユーザー名を入力してください：
パスワードを入力してください：

パスワードの追加は成功しました。
次の選択肢から入力してください(Add Password/Get Password/Exit)：

# Get Password が入力された場合
サービス名を入力してください：
## サービス名が保存されていなかった場合
そのサービスは登録されていません。
## サービス名が保存されていた場合
サービス名：hoge
ユーザー名：fuga
パスワード：piyo

次の選択肢から入力してください(Add Password/Get Password/Exit)：

# Exit が入力された場合
Thank you!
## プログラムが終了

# Add Password/Get Password/Exit 以外が入力された場合
入力が間違えています。Add Password/Get Password/Exit から入力してください。
```


登録に際して以下2つの場合は、当該ツールの処理の弊害となるため再度情報の入力を実行していただく必要があります。
- 既に同名のサービスとユーザーで登録されている場合(重複の排除)
- 「:」が使用されている場合(ツール内で区切り文字として使用しているため)

## パスワードの参照(Get Passwordを入力した場合

パスワードを保存し、出力するパスワードマネージャーをシェルスクリプトで作成します。パスワードの暗号化はしません。

以下の情報を保存・出力できるようにします。この情報はファイルに保存してください。

- サービス名
- ユーザー名
- パスワード

シェルスクリプトを実行すると、以下のメニューが表示されます。
## パスワードの変更(Change Passwordを入力した場合)


## 処理を終了したい場合(Exitを入力した場合)
Exit が入力されると、プログラムが終了します。
Exit が入力されるまではプログラムは終了せず、「次の選択肢から入力してください(Add Password/Get Password/Exit)：」が繰り返されます。

## どの選択肢にも当てはまらない場合



## ステップ3(任意)

パスワードが保存されたファイルを暗号化しましょう。ファイルが暗号化されていないとパスワードがファイルから直接確認可能なためセキュリティ上危険性が高いです。

暗号化には好きなツールを使っていただいて構いません。なお、有名なものには GnuPG(GNU Privacy Guard) があります。

具体的には、以下の仕様を追加します。

- Add Password が入力された場合、サービス名、ユーザー名、パスワードをファイルに保存した後にファイルを暗号化します
- 暗号化されたファイルを開いて、パスワードが読み取れないことを確認してください
- Get Password が入力された場合、暗号化されたファイルを復号化して（元の状態に戻して）サービス名、ユーザー名、パスワードを表示します。なおその際に、ファイルそのものは暗号化された状態を維持してください（Get Password後にファイルを開いてもファイルは暗号化されています）
