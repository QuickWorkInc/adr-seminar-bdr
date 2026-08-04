# Review: SendGrid Batch 015

- reviewed_at: 2026-08-04
- company_count: 25
- decision: approved
- personalization: Redash `small_industry` に基づく中業界別（人材派遣6社、Webアプリ・サービス運営7社、受託開発6社、不動産管理6社）
- individual_web_research: 実施なし
- exclusions: 契約顧客result `1123508`、既送信台帳、営業禁止・連絡先NG・倒産・非表示フラグを照合済み
- channel_priority: メールを最優先。送信不能時のみRedash `contact_form` が存在する企業をフォーム候補化し、URLなしは対象外
- slack: 個社通知なし。Batch完了時の集計1通のみ
