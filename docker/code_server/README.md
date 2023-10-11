# docker+code-server
dockerのコンテナ上でcode-serverを立て, 普段のvscode likeな環境と同じように開発できるようにしたもの, GPU版  
使い方やらは基本無印coderと同じ, ただしnvidia-dockerらGPU用の環境を整えるのが面倒  

# 対象
- vscode上でできることを計算機サーバー上でやりたい人  
- ユーザビリティが高いのでビギナー・玄人問わず  
- ただしクライアントPCを計算の間つけっぱなしにしてもいい人  

# 構成
★付きのファイルのみ弄る  
- coder_gpu  
    - ctn  
        - Dockerfile (containerの記述)  
        - ★requirements.txt (必要なpythonパッケージを指定)  
    - docker-compose.yml (composeの実行ファイル)  
    - ★.env (bindなどの設定ファイル)  
    - README.md  


***
# 事前準備
## クライアント(win)側
- windowsの想定  
- sshの設定  
    - 鍵のペア作成  
    - ホストマシン側に公開鍵導入  
- github/environmentをローカルに保存  
    - ```github/environment/Docker/codeserver/coder_gpu```のフォルダを用いる  

## サーバー(ホストマシン, linux)側
- 普段これらは終わっている想定  
    - セキュリティ設定  
    - sshの設定  
    - dockerのインストール  
    - docker-composeのインストール  
        - versionが>= 1.27である必要性 (現状の最新はv2.6.0)  
        - インストールは後述  
- coderフォルダを使用したいディレクトリに配置する  
    - だいたいは```/home/{user名}/{各自の名前}/coder_gpu```といった形なはず  
    - scp辺りで転送しておく  
- dockerでGPUを使うための環境整備  
    - nvidia-driverとnvidia-docker2をインストールする  
    - 詳細後述  


***
# HowToUse (ビギナー向け, ショート版)
- 基本的にユーザーが弄る部分は.env, ctn内のrequirements.txtのみ  
1. .env内のbind先(BIND_SRC)を書き換える  
    - ```BIND_SRC=/mnt/data1```などとする  
    - bind先：サーバーマシン内の領域かつコンテナと共有したい領域  
    - vimなどでlinux上で書き換える  
2. sshで計算機サーバーへアクセス  
    - ```ssh -i C:\Users\tadahaya\.ssh\id_rsa_XXXX -p 491XX hiegm4@133.11.XX.XX```  
    - win側にてpowershellを立てて上記を入力  
        - configに記載しておけばサボれる  
3. コンテナ立てる  
    - ```docker-compose up -d```  
    - ssh接続した計算機サーバー側で行う, docker-compose.ymlがあるdir (coder)で行う  
    - 初回の場合は```--build```オプションをつけてimageを作成する  
4. ポートフォワード  
    - ```ssh -N -L 8080:localhost:8888 -p 491XX -i C:\Users\tadahaya\.ssh\id_rsa_XXX tbtor1@133.11.XX.XX```  
    - win側にてpowershellを立てて上記を入力  
    - 手段はなんでもよいが, powershellの場合はもう一つ立てて行う点に注意 (ssh接続とポートフォワードは別立て)  
5. ```localhost:8888```にwinのブラウザでアクセスして解析開始  
6. 解析後, コンテナを終了する  
    - ```docker-compose down```  
    - ssh接続した計算機サーバー側で行う, docker-compose.ymlがあるdir (coder)で行う  


***
# HowToUse (詳細版)
- ポートが計4種類出てくるので違いを把握すること  
    - コンテナが晒すポート  
    - ホストマシンがコンテナを受けるポート  
    - クライアントマシンがホストマシンを受けるポート  
    - ホストマシンがssh接続用に開けているポート  
- 基本的にユーザーが弄る部分は.env, ctn内のrequirements.txtのみ  
1. .env内の書き換え  
    - 最低限bind先(BIND_SRC)を書き換える  
        - bind先: 計算機サーバー内のパス, コンテナ内のデータを永続化するため  
        - ホストマシンに合わせて書き換える  
        - 第一選択: ```/mnt/data1```などのマウントされたstorage用ディスク(外付けも可), 容量の心配が減る  
        - 第二選択: ```/home/[ホストのユーザー名]```, 手軽だが扱うデータ量によっては起動ディスクが死ぬ  
    - 基本不要だが必要に応じてHOST_PORTとBROWSER_PWを変更する  
        - 複数のdocker-composeをrunしたい場合はHOST_PORTを分ける必要がある  
2. 必要に応じてDockerfile内のpythonの部分などを弄って好きなモジュールを入れたりする  
    - ctn内のrequirements.txtに記入するだけ  
3. windows powershellを立てるなりしてsshで計算機サーバーへアクセス  
    - ```ssh -i C:\Users\[winのユーザー名]\.ssh\[秘密鍵名] -p [ホスト側のSSHポート] [ホストのユーザー名]@[ホストのIP]```  
    - 具体例: ```ssh -i C:\Users\tadahaya\.ssh\id_rsa_XXXX -p 491XX tbtor1@133.11.XXX.XXX```  
4. ```docker-compose up -d```でコンテナ立てる  
    - 初回の場合は```--build```オプションをつけてimageを作成する  
5. もう一つpowershellなりを立てて, ポートフォワード  
    - ```ssh -N -L [ブラウンジグ用のポート]:localhost:[.envでHOST_PORTで定義したポート] -p [ホスト側のSSHポート] -i C:\Users\[winのユーザー名]\.ssh\[秘密鍵名] [ホストのユーザー名]@[ホストのIP]```  
    - 具体例: ```ssh -N -L 8080:localhost:8888 -p 491XX -i C:\Users\tadahaya\.ssh\id_rsa_XXX tbtor1@133.11.XX.XX```  
6. winのブラウザに```localhost:[ブラウジング用のポート]```を打ち込むとアクセスできる  
    - 具体例: ```localhost:8080```
    - pwはdefaultだとcs24771になっている (.envから読み込むので打ち込む必要はない)  
    - 基本このままでいいと思うが, 細かいことを言うとセキュリティが気になりどころらしい  


***
# 各ファイルの中身
## docker-compose.yml


    services:
      ctn:
        build:
          context: ./ctn
          dockerfile: Dockerfile
        restart: always
        command: code-server --port 8080 --bind-addr=0.0.0.0:8080 /workspace --log debug
        ports:
          - '127.0.0.1:${HOST_PORT}:8080'
        environment:
          - PASSWORD=${BROWSER_PW}
        volumes:
          - type: bind
            source: ${BIND_SRC}
            target: /workspace
        tty: true
        deploy:
          resources:
            reservations:
              devices:
              - driver: nvidia
                capabilities: [gpu]
            limits:
              cpus: '0.9'


## .env


    ### environment file for codeserver

    ### must be modified
    # BIND_SRC: the path for bind in the host machine
    BIND_SRC=/mnt/data1


    ### if necessary
    # HOST_PORT: port for browsing
    HOST_PORT=8888

    # BROWSER_PW: PW for browsing
    BROWSER_PW=cs24771


***
# docker-composeのインストール
## 新たに入れる場合
1. DL  
    - ```sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose```  
    - ```v2.6.0```のところが更新される, 詳細は[リポジトリ参照](https://github.com/docker/compose/releases/)  
    - ```linux-x86_64```の部分はOSによるが, うちは基本ubuntu20.04なのでこれでOK  
2. 実行権限付与  
    - ```sudo chmod +x /usr/local/bin/docker-compose```  
3. インストールの確認  
    - ```docker-compose -v```  
    - versionが表示されればOK  
4. もし存在しないなどとエラーが出る場合, ```/usr/bin/docker-compose```とdockerが対応しているかもしれないので以下  
    - 先ほど入れたdocker-composeを削除: ```sudo rm -rf /usr/local/bin/docker-compose```  
    - DLの際のoutputを変更: ```-o /usr/bin/docker-compose```  
    - 2.の先も```/usr/bin/docker-compose```に変更  


# dockerでGPU環境を使うための環境構築
[ここ](https://qiita.com/karaage0703/items/e79a8ad2f57abc6872aa)を参考にする  
docker任せにすることでCUDA, cuDNN, PyTorchのバージョンに煩わされなくなる  
サーバーマシンはnvidia-driverさえ最新ならOKとのこと  
nvidia-driverとnvidia-dockerをインストールする  
## 1. nvidia-driverのインストール
2パターンある
### 1a. さくっと終わるケース
ubuntu18.04以降は以下でいけるらしい  
    
    sudo ubuntu-drivers autoinstall
    sudo shutdown -r now


### 1b. さくっと終わらないので手動で行うケース
  1. インストールすべきドライバのバージョン確認  
    
    apt update  
    sudo apt install ubuntu-drivers-common  
    ubuntu-drivers devices  
    
  2. ```nvidia-driver-XXXX```の中で最もバージョンが新しくrecommendedとなっているものを確認  
    - もしドライバがみつからない場合は, リポジトリを登録して再度トライ  
        
    sudo add-apt-repository ppa:graphics-drivers/ppa  
    sudo apt update  

  3. インストール  
    
    sudo apt install nvidia-driver-{確認したver}  
    sudo reboot  
    
## 2. nvidia-dockerのインストール
dockerのインストールは終わっているとする  
現在はnvidia-docker2が推奨されている模様  
以下でインストールできる ([参照](https://medium.com/nvidiajapan/nvidia-docker-%E3%81%A3%E3%81%A6%E4%BB%8A%E3%81%A9%E3%81%86%E3%81%AA%E3%81%A3%E3%81%A6%E3%82%8B%E3%81%AE-20-09-%E7%89%88-558fae883f44))  
    
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - 
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get -y install nvidia-docker2
    sudo pkill -SIGHUP dockerd

## 3. 確認
コンテナを立て, 以下のコマンドでtorchがcudaを扱えているか確認する  
    
    import torch
    print(
        torch.__version__,
        torch.cuda.is_available(),
        torch.cuda.device_count(),
        torch.cuda.get_device_name(),
        torch.cuda.get_device_capability()
    )
    

***
# 更新
- 220730  
  - v0.1.0, 全体構成の変更  
-  220609  
  - docker-composeのバージョンを更新し, .envを導入  


***
# 参考
[メイン](https://qiita.com/YKIYOLO/items/06cf44dead84188677ae)  
[docker-composeのインストール](https://qiita.com/kottyan/items/c892b525b14f293ab7b3)  
[docker-composeをWSL2に入れる](https://zenn.dev/taiga533/articles/11f1b21ef4a5ff)  
[WSL2にssh接続する](https://qiita.com/yuta-katayama-23/items/fad6928f37badf3391f2)  
[WSL2にssh接続する2](https://scratchpad.jp/ubuntu-on-windows11-5/)  
- 普通のlinuxマシン的に扱えばOKっぽい  