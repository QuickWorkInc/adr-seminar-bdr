# 常駐フォーム送信ランナー

Chrome拡張への接続ではなく、ローカルMac上の専用ChromeプロファイルにCDP接続してフォーム送信を継続するためのランナーです。送信キューと台帳を分離し、接続断・reCAPTCHAで他社への処理を止めません。

## 初回セットアップ

```zsh
cd seminar/form-runner
npm install
./start-dedicated-chrome.sh
./install-launch-agent.sh
```

既定ではヘッドレス（画面なし）で起動するため、フォーム操作中にChromeウィンドウが前面に出ることはありません。普段使いのChromeプロファイルとは分離され、プロファイルは`~/.form-runner/chrome-profile`に保存されます。

ログインが必要な場合だけ、いったん画面付きで起動します。

```zsh
./stop-dedicated-chrome.sh
FORM_RUNNER_HEADLESS=0 ./start-dedicated-chrome.sh
# 専用Chromeでログイン後
./stop-dedicated-chrome.sh
./start-dedicated-chrome.sh
```

`install-launch-agent.sh`は、ログイン時および60秒ごとに専用Chromeの稼働を確認します。Chromeが終了しても次回チェックで再起動します。停止する場合は`launchctl bootout gui/$(id -u)/com.salesnow.form-runner.chrome`を実行します。

## キュー形式

JSONL形式で、送信済みでない対象のみを`status: "approved"`で投入します。`fields`と`submit_selector`はフォームごとに事前確認して登録します。`--submit`を付けない限り送信ボタンは押しません。

```json
{"id":"法人番号","company_name":"株式会社例","url":"https://example.com/contact","status":"approved","fields":[{"selector":"input[name=company]","value":"株式会社SalesNow"},{"selector":"textarea[name=message]","value":"個社別に確認済みの文面"}],"submit_selector":"button[type=submit]"}
```

## 実行

```zsh
# 入力確認のみ（送信しない）
npm run run -- --queue /path/to/queue.jsonl --ledger /path/to/ledger.jsonl --max 10

# 承認済みキューを送信
npm run run -- --queue /path/to/queue.jsonl --ledger /path/to/ledger.jsonl --max 10 --submit

# 「入力内容確認」後の画面を確認用に保存する（最終送信は行わない）
npm run run -- --queue /path/to/queue.jsonl --ledger /path/to/ledger.jsonl --max 1 --submit --inspect
```

確認画面があるフォームは、`confirm_selector`に確認画面の最終送信ボタンを指定します。ランナーはreCAPTCHAを再確認してからそのボタンを押し、`success_selector`で完了を確認します。

確認画面の仕様が未確定な場合は、キューに`inspect_path`を設定して`--inspect`を実行できます。初段の「入力内容確認」まで進めたHTMLを保存し、最終送信は行いません。保存内容から`confirm_selector`と`success_selector`を確認してから通常の`--submit`を行います。

台帳に`sent`、`hold_recaptcha`、`hold_timeout`、`hold_unconfirmed`、`skipped`を都度記録します。次回実行時、これらのIDは再送しません。

## 制約

- reCAPTCHAは検出時点で`hold_recaptcha`に記録し、自動突破しません。
- `sent`は、キューに設定した`success_selector`が表示された場合だけ記録します。送信ボタンを押せても完了確認ができない場合は`hold_unconfirmed`として再送を防ぎます。
- 企業別文面・対象企業は、既存の確認フローで承認済みのものだけをキューに入れます。
