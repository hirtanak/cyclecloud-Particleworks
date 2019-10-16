# Azure CycleCloud template for Prometech Particleworks/Granuleworks

## Prerequisites

1. Prepaire for your Particleworks bilnary.
1. Install CycleCloud CLI

## How to install

1. tar zxvf cyclecloud-Particleworks.zip
1. cd cyclecloud-Particleworks
1. put your Particleworks binanry /blob directory.
1. Rewrite "Files" attribute for your binariy in "project.ini" file.
1. run "cyclecloud project upload azure-storage" for uploading template to CycleCloud
1. "cyclecloud import_template -f templates/pbs_extended_nfs_pw.txt" for register this template to your CycleCloud

## How to run Prometech Particleworks

1. set up your project directry and model.
1. qsub ./pwrun.sh (sample as below)

<pre><code>
#!/bin/bash
#PBS -j oe
#PBS -l select=1:ncpus=36
NP=36
# MPI settings HB anf HC setting
export MPI_ROOT="/shared/home/azureuser/apps/intel/impi/2018.4.274"
export I_MPI_ROOT=$MPI_ROOT
export I_MPI_DEBUG=5
export I_MPI_FABRICS=shm:ofa # for 2019, use I_MPI_FABRICS=shm:ofi
source /opt/intel/impi/2018.4.274/bin64/mpivars.sh
export LD_LIBRARY_PATH=/shared/home/azureuser/apps/pw-linux-package/module
export PARTICLE_LICENSE_FILE=27000@<license server IP Address>
export DISPLAY=localhost:0.0
"license server IP Address" "license server hostname" >> /etc/hosts
cd ${HOME}/apps/prj # move on project directory
${HOME}/apps/pw-linux-package/module/app.solver.double -p scene -k simd -n ${NP} 2>&1 | tee PWlog-`date +%Y%m%d_%H-%M-%S`.log
</pre></code>

## Known Issues
1. This tempate support only single administrator. So you have to use same user between superuser(initial Azure CycleCloud User) and deployment user of this template
1. master node may be fail if you choose DS3_v2 (14GB) due to shortage of memory requirement. Currently we set up D4s_v3 (16GB) as default
1. Support only CPU VMs. we have a plan to support GPU VMs.

# Azure CycleCloud用テンプレート:Prometech Particleworks/Granuleworks (NFS/PBSPro)

[Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/) はMicrosoft Azure上で簡単にCAE/HPC/Deep Learning用のクラスタ環境を構築できるソリューションです。（図はOSS PBS Proテンプレートの場合）

![Azure CycleCloudの構築・テンプレート構成](https://raw.githubusercontent.com/hirtanak/osspbsdefault/master/AzureCycleCloud-OSSPBSDefault.png "Azure CycleCloudの構築・テンプレート構成")

Azure CyceCloudのインストールに関しては、[こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/quickstart-install-cyclecloud) のドキュメントを参照してください。

Particleworks用のテンプレートになっています。
以下の構成、特徴を持っています。

1. OSS PBS ProジョブスケジューラをMasterノードにインストール
2. H16r, H16r_Promo, HC44rs, HB60rsを想定したテンプレート、イメージ
	 - OpenLogic CentOS 7.6 HPC を利用
	 - GPU仮想マシンは対応予定
3. Masterノードに512GB * 2 のNFSストレージサーバを搭載
	 - Executeノード（計算ノード）からNFSをマウント
4. MasterノードのIPアドレスを固定設定
	 - 一旦停止後、再度起動した場合にアクセスする先のIPアドレスが変更されない

![Particleworks/Granuleworks テンプレート構成](https://raw.githubusercontent.com/hirtanak/scripts/master/cctemplatedefaultdiagram.png " Particleworks/Granuleworks テンプレート構成")

## Particleworks/Granuleworks テンプレートインストール方法

前提条件: テンプレートを利用するためには、Azure CycleCloud CLIのインストールと設定が必要です。詳しくは、 [こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli) の文書からインストールと展開されたAzure CycleCloudサーバのFQDNの設定が必要です。

1. テンプレート本体をダウンロード
2. 展開、ディレクトリ移動
3. cyclecloudコマンドラインからテンプレートインストール 
   - tar zxvf cyclecloud-Particleworks<version>.zip
   - cd cyclecloud-Particleworks<version>
   - cyclecloud project upload azure-storage
   - cyclecloud import_template -f templates/pbs_extended_nfs_pw.txt
4. 削除したい場合、 cyclecloud delete_template Particleworks コマンドで削除可能

***
Copyright Hiroshi Tanaka, hirtanak@gmail.com, @hirtanak All rights reserved.
Use of this source code is governed by MIT license that can be found in the LICENSE file.

