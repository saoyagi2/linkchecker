# linkchecker

HTMLファイル群の内部リンクのリンク切れチェックを行います。

```
$ linkchecker.pl .
```

とすると、指定したディレクトリ以下の全てのファイルに対して内部リンクチェックを行います。ただし、ドットで始まるファイル及びディレクトリは無視します。

リンクチェックの対象となるのは以下の要素と属性です。

* a 要素の href 属性
* img 要素の src 属性
* link 要素の href 属性
* script 要素の src 属性

a 要素の href 属性では id 属性によるページ内位置指定にも対応しています。

外部リンクの場合はリンクチェックは行いません。

`<a href="dir/">` のようにリンク先がスラッシュで終わっている場合、`dir/index.html` へのリンクであると解釈します。

実行の出力結果は以下の通りです。

```
$ linkchecker.pl  .
index.html:5: error: no.css not found
index.html:13: error: nopage.html not found
index.html:17: error: noimg.jpg not found
index.html:21: error: noscript.js not found
dir/subpage.html:6: error: ../nopage.html not found
```

## 動作環境

Perl 5.8 以上がインストールされた環境で動作します。

モジュールとして

* HTML::Parser
* Getopt::Long

を使用しています。

## ライセンス

ライセンスは CC0 です。ご自由にご利用ください。

## オプション

以下のオプションを指定可能です。

### -v, --verbose

冗長表示を行います。具体的には target, link の全出力を行います。
実行例は以下の通りです。

```
$ linkchecker.pl --verbose .
index.html:5: info: link to base.css
index.html:6: info: link to no.css
index.html:6: error: no.css not found
index.html:9: info: link to https://www.yahoo.co.jp/
index.html:10: info: link to #id1
index.html:11: info: link to #noid
index.html:11: error: #noid not found
index.html:12: info: link to index.html#id1
index.html:13: info: link to page.html
index.html:14: info: link to nopage.html#id1
index.html:14: error: nopage.html#id1 not found
index.html:15: info: link to dir/subpage.html
index.html:16: info: link to img.jpg
index.html:17: info: link to noimg.jpg
index.html:17: error: noimg.jpg not found
index.html:19: info: link to script.js
index.html:20: info: link to noscript.js
index.html:20: error: noscript.js not found
index.html:21: info: link to //noscript.js
```
