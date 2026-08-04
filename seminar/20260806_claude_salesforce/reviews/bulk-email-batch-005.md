# Review: SendGrid Batch 005

- reviewed_at: 2026-08-04
- batch_path: `bulk-email-batch-005.tsv`
- company_count: 3
- decision: approved
- blocking_findings: なし
- 個社性: 金融機関向けSI、幅広いIT・IoT/AI事業、組込み・AI/IoT受託開発という各社の事業構造を、それぞれ長期商談管理、クロスセル、技術提案知見再利用へ接続。
- 宛先: Redashの公開営業または公式一般メール。privacy・採用・顧客サポート専用アドレスは不採用。
- 除外: 契約顧客result `1123508`、既送信台帳を照合済み。送信時にSendGridのbounce・block・spam report・global unsubscribeを再確認する。
- リンク: メール用 `sn_outmail` を使用。
