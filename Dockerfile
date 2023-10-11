# preprocess(openslide)とTransMIL(nystrom-attentionなど)の両用を想定
FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime
RUN apt update
RUN apt-get update
RUN apt install -y openslide-tools
RUN apt-get install -y build-essential libgl1-mesa-dev
#RUN python -m pip install scikit-learn==1.21.5 pandas==1.3.5 matplotlib==3.5.3 openslide-python==1.2.0 scikit-image==0.19.3 timm==0.6.7 opencv-python==4.6.0.66 albumentations==1.3.0 jupyer==1.0.0
RUN python -m pip install scikit-learn pandas matplotlib openslide-python scikit-image timm opencv-python albumentations jupyter seaborn
RUN python -m pip install tqdm requests nystrom-attention