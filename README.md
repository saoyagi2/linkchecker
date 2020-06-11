# linkchecker

HTMLファイル群の内部リンクのリンク切れチェックを行います。

```
$ linkchecker.pl .
```

とすると、指定したディレクトリ以下の全てのHTMLファイルに対して内部リンクチェックを行います。ただし、ドットで始まるファイル及びディレクトリは無視します。

リンクチェックの対象となるのは以下の要素と属性です。

* a 要素の href 属性
* img 要素の src 属性
* link 要素の href 属性
* script 要素の src 属性

a 要素の href 属性では id 属性によるページ内位置指定にも対応しています。

リンク先が外部リンクの場合はリンクチェックは行いません。

`<a href="dir/">` のようにリンク先がスラッシュで終わっている場合、`dir/index.html` へのリンクであると解釈します。

実行の出力結果は以下の通りです。

```
$ linkchecker.pl  .
index.html:5: no.css not found.
index.html:13: nopage.html not found.
index.html:17: noimg.jpg not found.
index.html:21: noscript.js not found.
dir/subpage.html:6: ../nopage.html not found.
```

## オプション

以下のオプションを指定可能です。

### -v, --verbose

冗長表示を行います。具体的には target, link の全出力を行います。
実行例は以下の通りです。

```
$ linkchecker.pl --verbose .
target: page.html
link: index.html
target: index.html
link: base.css
link: no.css
index.html:5: no.css not found.
link: https://www.yahoo.co.jp/
link: page.html
link: #id1
link: index.html#id1
link: nopage.html
index.html:13: nopage.html not found.
link: dir/subpage.html
link: img.jpg
link: noimg.jpg
index.html:17: noimg.jpg not found.
link: script.js
link: noscript.js
index.html:21: noscript.js not found.
link: //noscript.js
target: dir/subpage.html
link: ../index.html
link: ../nopage.html
dir/subpage.html:6: ../nopage.html not found.
link: ../
```
