# wsi_preprocess
病理画像の前処理用のツールを集めたもの。

# 環境構築
本ライブラリではopenslideというライブラリを使用しており, パッケージに加えてそれを使うためのツールをインストールする必要がある
。  
(231006追記) 画像のぼやけた部分の検出にはOpenCVを使っているため, 使う方はそちらもインストールしてください。
```
apt install -y openslide-tools
pip install openslide-python cv2
```
dockerディレクトリにCUI DockerとCode ServerのDocker, docker-compose.yamlがるので参照してください。

# 含まれているツール
## 背景の判別・除去(saturation_otsu.py) 
WSIから背景部分を除き, 組織が含まれるpatchを取り出すツール。  
様々な手法を検討した結果, patchの彩度の平均値に対してOTSU法を用いる手法が最も性能が良かった(見た目)ため, その手法を採用している。

## ぼやけた部分の検出(blur_laplacian.py)
WSIの中のぼやけた部分をラプラシアンフィルタによって検出する。現在はフィルタの値をそのまま出力しており, 画像自体の性質によってthresholdは変わるためこのツールはまだ使いにくいと思います。

# 実行例
exampleディレクトリ内にツールを使っている例があります(処理する病理画像は含まれていません)。


