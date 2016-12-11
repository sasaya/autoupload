自動エンコード＆Youtubeアップロード

動作環境　Miniconda　python 3.x

対応動画拡張子　AVI, MP4

内容物
.
├── INPUT                  処理したい動画を入れるフォルダ(無い場合は作ってください)
├── auto.bat               主に使われるバッチファイル
├── installgoogleapi.bat   GoogleAPIインストール用バッチファイル
├── Readme.txt             れどめ
├── client_secrets.json    Youtube Data API v3 認証用ファイル
├── main.py                auto.batから呼び出されるスクリプト’自動エンコード
├── uploadvideo.py         auto.batから呼び出されるスクリプト’Youtubeアップロード
├── auc                    Aviutlcontrol
├── aviutl100              Aviutl本体
└── start.bat              うまく動作しない場合はlog.txtが出力されていますので確認できます。

使い方

１．　http://conda.pydata.org/miniconda.html　からPython3.xをダウンロードしてダウンロード,インストール

２．　installgoogleapi.batを起動。うまく起動しない場合は管理者権限で起動してください。
　　　*ここで自動Youtubeアップロードのためのモジュールをインストールします。

３．　INPUTフォルダに動画ファイルを入れる。

４.　 start.bat　の起動　
      *初回起動時はGoogleアカウント認証があります。

５.　ENCODEDにエンコード済みファイル，COMPLETEDに元動画ファイルが移動されます。


制作　Quickdraww　
連絡先（Discord）　https://discord.gg/mnnDYUP


参考

バッチファイル単体での権限昇格
http://qiita.com/jTakasuRyuji/items/e7bd576ed57969b2d06e

Aviutl自動化　Pythonスクリプト(2.x)
http://blog.wizaman.net/archives/427