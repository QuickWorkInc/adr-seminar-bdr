# Review: SendGrid Batch 004

- reviewed_at: 2026-08-04
- batch_path: `bulk-email-batch-004.tsv`
- company_count: 3
- decision: approved
- blocking_findings: なし
- 個社性: 各社の公式事業情報を、営業データ整備・報告自動化・提案知見再利用・クロスセル／更新／失注再提案へ接続。
- 宛先: Redashの公開メール。privacy、採用、カスタマーサポート用途のアドレスは不採用。
- 除外: 契約顧客result `1123508`、既送信台帳を照合済み。送信時にSendGridのbounce・block・spam report・global unsubscribeを再確認する。
- リンク: メール用 `sn_outmail` を送信スクリプトで使用。
