# seminar

各セミナー情報と開催回ごとのアウトバウンド作業場所を置きます。

## 管理シート

チームで使っているセミナー管理シートは `management-sheet.md` に格納しています。

- [セミナー管理シート](management-sheet.md)
- [配信ログ正本スプレッドシート](delivery-log-sheet.md)
- [SalesNowデータ / Redash活用ルール](salesnow-data-redash.md)

## 鉄の掟

すべてのアプローチ文面は、対象セミナー内容を読んだ上で、対象企業ごとの参加ベネフィットを必ず入れること。メール、問い合わせフォーム、SNSの全チャネルで企業別パーソナライズを必須にします。

禁止:

- セミナー概要を読まずに文面を作る
- 企業情報を読まずに文面を作る
- 「貴社の営業活動に役立ちます」のような汎用表現だけで済ませる
- 社名だけを差し替えた文面を作る

必須:

- セミナーで扱うテーマ、登壇者、アジェンダ、得られる示唆を明記する
- 対象企業の事業、顧客、販売体制、直近の動きに接続する
- 経営ベネフィットとP/Lインパクトを明示する
- 根拠となるURL、資料、調査メモを残す
- 配信ログは1配信につき1行で `delivery-log-sheet.md` のスプレッドシートへ集約する
- ターゲティング、問い合わせフォーム探索、メールアドレス取得では `salesnow-data-redash.md` に従いSalesNowデータをRedash経由で徹底利用する

## 開催回フォルダ

命名規則:

```text
YYYYMMDD_topic_name
```

推奨構成:

```text
seminar/<開催ID>/
  brief.md
  target-companies.md
  company-research/
  drafts/
  reviews/
  sent-log.md
```

## 開催回一覧

- `20260804_claude_salesforce`
- `20260806_claude_salesforce`
