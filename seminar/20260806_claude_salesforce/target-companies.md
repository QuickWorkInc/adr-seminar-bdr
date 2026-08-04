# 対象企業リスト

対象企業ごとに、企業情報・仮説・チャネル別文面の作成状況を管理します。

## 母集団

- 指定10業界の企業数（法人番号重複除外）: 482,458社
- うち企業Webサイトあり: 325,342社
- 取得元: Redash result `1253126`
- 問い合わせフォーム有無は未集計

## 初回アプローチ候補（既存顧客・倒産フラグ除外済み）

| 優先 | 企業名 | 法人番号 | 従業員数 | 電話番号 | 公開メール | 状態 |
|---:|---|---|---:|---|---|---|
| 1 | 株式会社スタッフサービス | 8010001076758 | 98,050 | 0120-022-022 | なし | 問い合わせフォーム送信完了（2026-08-04） |
| 2 | 株式会社リクルートスタッフィング | 4010001032038 | 74,730 | 03-6636-4525 | なし | 送信見送り（企業向け人材依頼フォームのみ） |
| 3 | 日本生命保険相互会社 | 3120005007273 | 63,157 | 06-6209-4500 | なし | 送信見送り（契約者・一般意見窓口のみ） |
| 4 | 明治安田生命保険相互会社 | 8010005007932 | 50,075 | 03-3283-8111 | なし | 有効候補 |
| 5 | 第一生命保険株式会社 | 1010001174683 | 47,342 | 03-3216-1211 | なし | 有効候補 |
| 6 | 住友生命保険相互会社 | 5120005007271 | 41,307 | 06-6937-1435 | なし | 有効候補 |
| 7 | マンパワーグループ株式会社 | 5020001016039 | 39,626 | 045-227-4400 | なし | 有効候補 |
| 8 | トランス・コスモス株式会社 | 3011001041302 | 36,979 | 050-1751-7700 | なし | 有効候補 |
| 9 | 株式会社パソナ | 1010001067359 | 36,638 | 03-6734-1111 | なし | 有効候補 |
| 10 | 東山産業株式会社 | 1013201017141 | 336 | 03-3713-3456 | info@higashiyama.com | 問い合わせフォーム送信完了（2026-08-04） |

## 除外

- テンプスタッフ・クリエイティブ株式会社（法人番号 7010401047319）: Redashの倒産フラグが有効
- SalesNow既存顧客10社: 契約顧客リストとの照合で除外

## メール送信済み

| 企業名 | 法人番号 | 宛先 | Redash結果 | 送信結果 |
|---|---|---|---|---|
| フジアルテ株式会社 | 7120001035464 | info@fujiarte.co.jp | 1253255 | SendGrid accepted（2026-08-04） |
| アクセンチュア株式会社 | 7010401001556 | info.tokyo@accenture.com | 1253255 | SendGrid accepted（2026-08-04） |
| 株式会社ワークスタッフ | 7480001001711 | workstaff@ws-gp.co.jp | 1253255 | SendGrid accepted（2026-08-04） |
| 株式会社インターネットイニシアティブ | 6010001011147 | info@iij.ad.jp | 1253272 | SendGrid accepted（2026-08-04） |
| 株式会社NTTデータ・アイ | 2011101056358 | info@nttd-i.co.jp | 1253272 | SendGrid accepted（2026-08-04） |
| セントラルコンサルタント株式会社 | 1010001088264 | central@central-con.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| 株式会社クマヒラ | 1010001108872 | info@kumahira.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| 株式会社IIJグローバルソリューションズ | 1010001139901 | info@iijglobal.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| 株式会社Preferred Networks | 1010001159494 | pfn-info@preferred.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| 株式会社アイスタイル | 1010401057595 | istyle-info@istyle.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| アディッシュ株式会社 | 1010701029988 | info@adish.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| 株式会社サウンズグッド | 1011001062713 | info@sounds-good.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| イグニション・ポイント株式会社 | 1011001100423 | info@ignitionpoint-inc.com | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 001） |
| 株式会社エヌデーデー | 1011201000828 | inquiry@nddhq.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 株式会社アスカ | 1070001006063 | info@asuka-hu.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 日精樹脂工業株式会社 | 1100001011530 | info@nisseijushi.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 株式会社デジタルアイデンティティ | 1011001117178 | inquiry@digitalidentity.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 富士テクノロジー株式会社 | 1080001012804 | info@fut.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 株式会社シー・エス・ランバー | 1040001057646 | info@c-s-lumber.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 株式会社フィールドサーブジャパン | 2010001091903 | info@field-serve.com | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 株式会社トゥインクル | 1013401001399 | info@twk.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 002） |
| 株式会社サーバーワークス | 1011101054073 | sales@serverworks.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003） |
| ジオマテック株式会社 | 1020001013421 | sales@geomatec.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003） |
| 株式会社カスタマーリレーションテレマーケティング | 1120001123274 | information@crtm.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003） |
| 株式会社ワークステーション | 1120001092585 | info@workstation.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003、重複1通あり） |
| 株式会社みどり会 | 1120001090457 | info@midorikai.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003、重複1通あり） |
| 三和エンジニアリング株式会社 | 1010001070040 | info@sanwa-e.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003、重複1通あり） |
| 株式会社コーユービジネス | 1120001079599 | mail@koyu.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003） |
| 東洋炭素株式会社 | 1120001050238 | info@toyotanso.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 003） |
| 株式会社KPMG FAS | 1010001075808 | fasmktg@jp.kpmg.com | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 004） |
| ボッシュ・レックスロス株式会社 | 1011001047004 | info@boschrexroth.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 004） |
| 株式会社CIJ | 1020001015606 | info@cij.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 004） |
| NTTデータフォース株式会社 | 1020001037724 | sales-contact@nttdata-force.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 005） |
| NSW株式会社 | 1011001017717 | webmaster@gw.nsw.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 005） |
| 株式会社DTSインサイト | 1012401004635 | webmaster@dts-insight.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 005） |
| 興人フィルム＆ケミカルズ株式会社 | 1010001147706 | information_kjfc@kohjin.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 006） |
| 平河ヒューテック株式会社 | 1010701008364 | soumu@hewtech.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 006） |
| 岩瀬産業株式会社 | 1070001013126 | webmaster@iwase-net.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 006） |
| タキゲン製造株式会社 | 1010701005766 | tokyo@takigen.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 007） |
| セメダイン株式会社 | 1010701005270 | sodan@cemedine.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 007） |
| 日本エア・リキード合同会社 | 1010401089977 | Webmaster-aljp@airliquide.com | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 007） |
| 日本電波工業株式会社 | 1011001017865 | callct@ndk.com | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 008） |
| 株式会社三菱電機ライフネットワーク | 1010601030369 | Mitsubishiln-Net@lnet.mellife.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 008） |
| ブリッジインターナショナルグループ株式会社 | 2010901015622 | mktg@bridge-g.com | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 009） |
| CTCファーストコンタクト株式会社 | 2011001062349 | ctcfc-sales@ctc-g.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 009） |
| 株式会社システムエグゼ | 2010001019680 | mktg@system-exe.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 010） |
| 株式会社GOOYA | 2011001062274 | info@gooya.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 010） |
| 株式会社HAL | 2011001048331 | info@hal21.co.jp | 1253283 | SendGrid accepted（2026-08-04、一斉Batch 010） |

メール送信済み48社はいずれも契約顧客result `1123508`に該当せず、送信前のbounce・block・spam report・unsubscribeは0件。Batch 003ではプロセス重複により3社へ各1通の重複送信が発生し、実配送は11件。詳細と恒久対策は `sendgrid-duplicate-incident-20260804.md` を参照。

## フォーム未送信

- 東京パワーテクノロジー株式会社: 公式フォームへ入力したが、送信ボタンのサイト側JavaScriptエラー（`sendProc is not defined`）により未送信。実績には未計上。

## フォーム送信済み

| 企業名 | 法人番号 | 公式フォーム | Redash結果 | 送信結果 |
|---|---|---|---|---|
| 株式会社スタッフサービス | 8010001076758 | https://www.staffservice.co.jp/contact/contact.php?t=02 | 1253159 | 完了画面確認（2026-08-04） |
| 東山産業株式会社 | 1013201017141 | https://www.higashiyama.com/contact/ | 1253283 | 完了画面確認（2026-08-04 16:04 JST） |
| ワタキューセイモア株式会社 | 7130001037872 | https://www.watakyu.co.jp/cgi/form/contact/ | 1253321 | 完了メッセージ確認（2026-08-04） |
| 太平ビルサービス株式会社 | 2011101012138 | https://www.taihei-bs.co.jp/contact/etc.html | 1253322 | 完了画面確認（2026-08-04） |
| TISI株式会社 | 2010001134133 | https://www.tisi.jp/contact/common/ | 1253322 | 完了画面確認（2026-08-04） |

## 連絡先確認メモ

- 株式会社スタッフサービス: `https://www.staffservice.co.jp/contact/contact.php?t=02` の一般質問フォームから送信し、完了画面を確認。営業利用禁止の明示なし。
- 東山産業株式会社: `https://www.higashiyama.com/contact/` の総合フォームで「その他」を選択して送信し、`/contact/complete/` の完了画面を確認。営業利用禁止の明示なし。
- ワタキューセイモア株式会社: 一般問い合わせフォームから送信し、「ありがとうございます。メッセージは送信されました。」を確認。Redashの営業禁止・連絡先NGフラグはいずれも無効で、公式ページにも営業利用禁止の明示なし。
- 太平ビルサービス株式会社: 「お仕事や採用以外」の一般問い合わせフォームから送信し、`/contact/comp_etc.html` の完了画面を確認。公式ページに営業利用禁止の明示なし。
- TISI株式会社: 公式の一般問い合わせフォームから送信し、`/contact/complete.php` の「問い合わせ完了」画面を確認。Redashの営業禁止・連絡先NGフラグはいずれも無効で、公式ページにも営業利用禁止の明示なし。

メール送信済み48社、フォーム送信済み5社、ユニーク合計53社。
