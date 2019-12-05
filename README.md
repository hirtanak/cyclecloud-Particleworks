# Azure CycleCloud template for Promect Particleworks

## Prerequisites
1. Prepaire for your Particleworks bilnary.
1. Install CycleCloud CLI

## How to install 
1. tar zxvf cyclecloud-Particleworks<version>.tar.gz
1. cd cyclecloud-Particleworks<version>
1. put Particleworks binary/model on <template>/blob directory.
1. Rewrite "Files" attribute for your binariy in "project.ini" file. 
1. run "cyclecloud project upload azure-storage" for uploading template to CycleCloud
1. "cyclecloud import_template -f templates/slurm_extended_nfs_pw.txt" for register this template to your CycleCloud

## Known Issues
1. This tempate support only single administrator. So you have to use same user between superuser(initial Azure CycleCloud User) and deployment user of this template
1. Currently AutoScale is disabled. you have to create execute node and get IP. In addtion, create hosts file for your execute node environment.

# Azure CycleCloud用テンプレート:PW(NFS/Slurm)

[Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/) はMicrosoft Azure上で簡単にCAE/HPC/Deep Learning用のクラスタ環境を構築できるソリューションです。


Azure CyceCloudのインストールに関しては、[こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/quickstart-install-cyclecloud) のドキュメントを参照してください。

Partickeworks用のテンプレートになっています。
以下の構成、特徴を持っています。

1. SlurmジョブスケジューラをMasterノードにインストール
1. CPU: H16r, H16r_Promo, HC44rs, HB60rsを想定したテンプレート、イメージ
	 - OpenLogic CentOS 7.6 HPC を利用 
   GPU: 2019/12/6現在, DSVMイメージを利用
1. Masterノードに512GB * 2 のNFSストレージサーバを搭載
	 - Executeノード（計算ノード）からNFSをマウント
1. MasterノードのIPアドレスを固定設定
	 - 一旦停止後、再度起動した場合にアクセスする先のIPアドレスが変更されない

![テンプレート構成](https://raw.githubusercontent.com/hirtanak/scripts/master/20191206-particleworks.jpg "テンプレート構成")

Particleworksテンプレートインストール方法

前提条件: テンプレートを利用するためには、Azure CycleCloud CLIのインストールと設定が必要です。詳しくは、 [こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli) の文書からインストールと展開されたAzure CycleCloudサーバのFQDNの設定が必要です。

1. テンプレート本体をダウンロード
1. 展開、ディレクトリ移動
1. Particleworks本体ファイルの準備(例: Particleworks 6.2.2 190807_205925_linux.zip)
1. project.iniファイルの設定（Particleworksファイル名の指定）、Particleworksファイルの指定
   - ファイル名の記載のある"Files"行でParticleworks本体ファイル名を指定します。
1. cyclecloudコマンドラインからテンプレートインストール 
   - tar zxvf cyclecloud-Particleworks<version>.tar.gz
   - cd cyclecloud-Particleworks<version>
   - cyclecloud project upload azure-storage
   - cyclecloud import_template -f templates/slurm_extended_nfs_pw.txt
1. 削除したい場合、 cyclecloud delete_template Particleworks コマンドで削除可能

ジョブ実行の方法

1. プロジェクトディレクトリの作成・移動
1. sbatchコマンドでSlurmへジョブを投入
　 GPU: sbatch -c 6 -n 1 pwgpurun.sh
   CPU: sbatch -c 44 -n 1 -p htc pwcpurun.sh 

***
Copyright Hiroshi Tanaka, hirtanak@gmail.com, @hirtanak All rights reserved.
Use of this source code is governed by MIT license that can be found in the LICENSE file.
