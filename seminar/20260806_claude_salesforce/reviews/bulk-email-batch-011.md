# Review: SendGrid Batch 011

- reviewed_at: 2026-08-04
- batch_path: `bulk-email-batch-011.tsv`
- company_count: 2
- decision: approved
- blocking_findings: なし
- 個社性: 製造業向け設計・PLM営業と、自治体向け複数事業を、それぞれ導入事例再利用・PLMクロスセル・自治体間の横展開へ接続。
- 宛先: Redashの公開公式一般メール。
- 除外: 契約顧客result `1123508`、既送信台帳を照合済み。送信時にSendGridのbounce・block・spam report・global unsubscribeを再確認する。
- リンク: メール用 `sn_outmail` を使用。
