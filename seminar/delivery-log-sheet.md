# 配信ログ正本スプレッドシート

配信ログはこのGoogle Sheetsを正本とします。

## 鉄の掟

1配信につき1行で、必ずこのスプレッドシートに記録します。ローカルMarkdown、個人メモ、Slack投稿だけを正本にすることは禁止です。

## 正本

- Google Sheets: https://docs.google.com/spreadsheets/d/1oQZMXewYMeC1a3075JX7IRx7fLwHSLoiithL1yj-KG8/edit?gid=0#gid=0
- Sheet ID: `1oQZMXewYMeC1a3075JX7IRx7fLwHSLoiithL1yj-KG8`
- gid: `0`

## 必須列

- 対象セミナー
- 配信セグメント
- 配信件数
- 配信手法
- ベースメッセージ
- 企業名
- チャネル
- 宛先/URL
- 文面ファイル
- 送信者
- 送信根拠
- 結果
- opt-out
- bounce/complaint
- next_action_allowed_at
- 備考

## 運用ルール

- メール、問い合わせフォーム、SNSのどの配信でも、このシートに1行を追加する
- 複数企業に同じ配信をした場合も、配信単位で1行にまとめ、配信件数を必ず記録する
- 実際に配信する際、ベースとして使ったメッセージ文章を `ベースメッセージ` に記録する
- Slack通知やローカルファイルは補助であり、配信ログの正本ではない
