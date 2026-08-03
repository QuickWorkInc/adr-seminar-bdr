# email

アウトバウンドメール送信に関する運用、テンプレート、レビュー基準を置きます。

## SendGrid送信CLI

`send-email.mjs` はSendGrid Web API v3を使う1通ずつの送信CLIです。誤送信を避けるため、通常実行はドライランになり、実送信には `--send` と宛先を再入力する `--confirm` の両方が必要です。

### 必要環境

- Node.js 20以上
- SendGridで認証済みの送信元アドレス
- Mail Send権限を持つSendGrid APIキー

設定例をコピーし、値はローカル環境にだけ保存してください。`.env` と送信ログはGitHubへコミットされません。

```bash
cp email/.env.example .env
set -a
source .env
set +a
```

APIキーをコード、メッセージJSON、Markdown、送信ログへ書かないでください。

### メッセージ作成と確認

`email/messages/example.json` をコピーして1社・1名ごとのJSONを作ります。実送信前に、対象キャンペーンの `brief.md`、企業調査、文面、レビュー承認、配信停止・苦情・バウンス・再送禁止の記録を確認してください。

```bash
node email/send-email.mjs --message email/messages/example.json
```

ドライランが通った後だけ、宛先を完全一致で再指定して送信します。

```bash
node email/send-email.mjs \
  --message email/messages/company-person.json \
  --send \
  --confirm recipient@example.com
```

SendGridが `202 Accepted` を返した場合、宛先そのものを含まない監査ログを `email/.local/sent-log.jsonl` に記録します。`202` は受付完了であり、最終配信完了を意味しません。バウンス、苦情、配信停止はSendGrid側でも確認し、キャンペーンの送信ログへ反映してください。

### 必須JSON項目

- `to.email`, `subject`, `text`
- `metadata.campaignId`, `metadata.companySlug`, `metadata.recipientRole`
- `metadata.personalizationEvidence`, `metadata.businessImpact`
- `metadata.sourceReferences`（1件以上）
- `metadata.reviewApproved: true`
- `metadata.suppressionChecked: true`
- `metadata.suppressionCheckedAt`（ISO 8601日時）

HTML本文、返信先、SendGrid配信停止グループは任意です。配信停止グループを使う場合は `SENDGRID_UNSUBSCRIBE_GROUP_ID` を設定します。

## 鉄の掟

メール営業では、各社ごとにパーソナライズした文面を必ず入れる。

送信禁止:

- 社名だけ差し替えたメール
- 業界名だけ差し替えたメール
- セミナー内容が本文に接続されていないメール
- 経営ベネフィット、P/Lインパクトがないメール
- 対象企業の具体情報が1つもないメール
- 配信停止、苦情、バウンス、再送禁止の記録を確認していないメール

## 必須構成

1. 企業固有の冒頭フック
2. セミナー内容との接続
3. 経営ベネフィット
4. P/Lインパクト
5. 参加すると得られる示唆
6. 申込CTA

## レビュー基準

- 対象企業の公式情報または信頼できる根拠に基づいている
- 読み手の役職と責任範囲に合っている
- 誇張や断定がない
- SalesNow側の都合ではなく、相手企業の意思決定メリットが中心になっている
- 送信ログに送信根拠、配信停止、苦情、次回接触可能日を記録できる
