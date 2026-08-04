# SalesNow ADR Seminar BDR

SalesNowで開催するセミナー集客におけるアウトバウンド営業の作業リポジトリです。

## 鉄の掟

メール営業、問い合わせフォーム営業、SNS営業のすべてで、各社ごとにパーソナライズした文面を必ず入れる。

以下を満たさない文面は作成・送信・レビュー通過を禁止します。

1. セミナー内容を読み取り、対象企業にとってなぜ参加価値があるかを明記する
2. 対象企業の事業、顧客、直近の動き、経営課題を読み取り、企業固有の文脈を入れる
3. 経営ベネフィット、P/Lインパクト、売上・粗利・CAC・商談創出・工数削減などの事業インパクトを明確に伝える
4. 汎用テンプレート、業界名だけの差し替え、社名だけの差し替えを禁止する
5. 設計・オーケストレーション・最終レビューは上位モデルが担い、量産担当の出力を必ず検証する

## フォルダ構成

- `seminar/`: 各セミナー情報と開催回ごとの作業場所
- `email/`: アウトバウンドメール送信に関する運用、テンプレート、レビュー基準
- `contact/`: 問い合わせフォーム営業に関する運用、テンプレート、レビュー基準
- `sns/`: SNS営業に関する運用、テンプレート、レビュー基準

## セミナー別の作業単位

開催ごとに `seminar/YYYYMMDD_topic_name/` を作ります。

例:

- `seminar/20260804_claude_salesforce/`

並行稼働する場合も、各ターミナルは対象セミナーのフォルダを作業起点にしてください。

## 必須ワークフロー

1. `seminar/<開催ID>/brief.md` にセミナー情報を整理する
2. Redash経由のSalesNowデータを使ってターゲティング、問い合わせフォームURL、メールアドレス候補を取得する
3. 対象企業ごとに企業情報を調査し、根拠を `company-research/` に残す
4. `brief.md` の未確定事項が消えるまで文面作成・送信を禁止する
5. チャネル別に `email/` `contact/` `sns/` のルールを参照して文面を作る
6. 企業ごとに `reviews/<company-slug>.md` へ上位モデルレビュー結果を残す
7. `scripts/validate-repo.sh` で構成と必須ルールを確認する
8. 実キャンペーン送信前は `bash scripts/validate-repo.sh --campaign seminar/<開催ID>` を通す
9. 配信ログは1配信につき1行で `seminar/delivery-log-sheet.md` の正本スプレッドシートへ集約する
10. 変更をコミットする
11. コミット後はGitHubとSlackへ同期する

## SalesNowデータ / Redash

`/adr-seminar-bdr` 配下の全プロジェクトでDBを参照する場合は、必ずRedash経由で接続します。DBへの直接接続は行いません。

- Redash接続先: `https://redash.office.salesnow.jp/`
- APIキーはユーザーがクリップボードへコピーし、実行時に直接 `Authorization: Key ...` ヘッダーへ渡す
- APIキーの実値を画面、コマンド出力、Markdown、CSV、チャット、配信ログへ表示しない
- APIキーをファイルへ保存しない（ユーザーが明示的に保存を依頼した場合を除く）
- クリップボードが空の場合のみ、ユーザーへ再コピーを依頼する
- 既存クエリ、データソース、スキーマの順に確認し、必要なデータを取得する

ターゲティング、問い合わせフォーム探索、メールアドレス取得では、`seminar/salesnow-data-redash.md` の鉄の掟に従い、SalesNowデータをRedash経由で徹底利用します。

## Slack通知

このリポジトリの `main` への変更は、`post-commit` hook からSlackへ通知します。親投稿には端的なタイトルと内容だけを書き、詳細はスレッドに送ります。

営業キャンペーンの開始・30分ごとの中間進捗・完了報告も、リポジトリのローカルGit設定 `adr-seminar-bdr.slack-webhook-url` に保存した共通Webhookを使用します。Webhook実値は画面・ログ・Markdownへ表示せず、Git管理ファイルへコミットしません。

Webhook URLやSendGrid API Keyは秘匿値のためコミットしません。ローカルでは次のどちらかで設定します。

```bash
git config --local adr-seminar-bdr.slack-webhook-url "<Slack Incoming Webhook URL>"
```

または:

```bash
cp .env.example .env.local
```

`.env.local` に `SLACK_WEBHOOK_URL` を設定します。

スレッド投稿まで行う場合は、Incoming WebhookではなくSlack Bot TokenとChannel IDを設定します。

```bash
SLACK_BOT_TOKEN=
SLACK_CHANNEL_ID=
```

メール送信はSendGridを使用します。SendGrid APIキーはリポジトリのローカルGit設定 `adr-seminar-bdr.sendgrid-api-key` に保存し、`/adr-seminar-bdr` 配下で共通利用します。APIキーの実値は画面、コマンド出力、Markdown、CSV、チャット、配信ログへ表示せず、Git管理ファイルへコミットしません。ローカル設定がない場合のみクリップボードから読み取ります。

Redashを使うデータ取得スクリプトは、Redash用クリップボード認証手順を使用します。SendGridキーはローカルGit設定、Redashキーはクリップボードと認証経路を分離します。

通知の親投稿は、人が把握しやすいように `タイトル + 変更ファイル数` のみにします。スレッドには、コミット、変更ファイル、変更サマリ、改変詳細diff、配信ログ正本スプレッドシートを送ります。Incoming Webhookのみの場合はSlack仕様上スレッドIDを取得できないため、親投稿だけ送ります。

## GitHub同期

リモートは以下を正とします。

```bash
git remote set-url origin https://github.com/QuickWorkInc/adr-seminar-bdr.git
```

このリポジトリでは、コミット後に自動で `origin` へpushするためのGit hookを用意しています。

```bash
bash scripts/install-git-hooks.sh
```

`pre-commit` はルール検証を通らない変更を止め、`post-commit` は `main` をGitHubへpushします。同期状態は次で確認できます。

```bash
bash scripts/check-sync-status.sh
```

手動で同期する場合:

```bash
bash scripts/sync-to-github.sh
```
