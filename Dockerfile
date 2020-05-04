FROM ubuntu:bionic as jjlin-base
WORKDIR /opt

# Ubuntu jjlin-base
# ============================================================= 
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata &&\
    rm -rf /var/lib/apt/lists/* &&\
    apt-get update &&\
    apt-get install -y \
                       ca-certificates \
                       gnupg2 \
                       apt-utils \
                       build-essential \
                       software-properties-common &&\
    # Curl
    # ============================================================= 
    apt-get update &&\
    apt-get install -y \
                       libssl-dev \
                       libxml2-dev \
                       libcurl4-openssl-dev \
                       curl &&\
    # Python-pip
    # ============================================================= 
    apt-get update &&\
    apt-get install -y \
                       build-essential \
                       python3-dev \
                       python3-pip &&\
    # Wget, text editing, session, unzip, and version control utils
    # ============================================================= 
    apt-get update &&\
    apt-get install -y \
                       wget \
                       vim \
                       tmux \
                       git \
                       unzip \
                       openssh-server &&\ 
    # GNU-parallel
    # ============================================================= 
    apt-get update &&\
    apt-get install -y \
                       parallel

# R-base
# ============================================================= 
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 &&\
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" &&\
    apt-get update &&\
    apt-get install -y \
                       r-base

# R dev packages
# ============================================================= 
RUN R --no-save -e 'install.packages("BiocManager"); BiocManager::install();' &&\
    R --no-save -e 'BiocManager::install(c("devtools","roxygen2"));' &&\
    R --no-save -e 'library(devtools); install_github("jalvesaq/colorout");'

# R bioinformatics packages
# ============================================================= 
RUN apt-get update &&\
    apt-get install -y pandoc &&\
    R --no-save -e 'BiocManager::install(c( \
#                                            "BiocParallel",\
                                           "data.table",\
#                                            "stringr",\
#                                            "jsonlite",\
#                                            "rmarkdown",\
#                                            "RColorBrewer",\
                                           "ggplot2",\
                                           "ggpmisc",\
                                           "ggseqlogo",\
#                                            "gtools",\
#                                            "kableExtra",\
                                           "Biostrings",\
#                                            "GenomicAlignments",\
#                                            "GenomicRanges",\
#                                            "Rsamtools",\
#                                            "Rsubread",\
#                                            "rtracklayer",\
                                           "ShortRead",\
#                                            "apeglm",\
#                                            "DESeq2",\
#                                            "edgeR",\
                                           ""\
                                           ))'

# # Seqtk
# # ============================================================= 
# RUN wget https://github.com/lh3/seqtk/archive/v1.3.tar.gz -O seqtk-1.3.tar.gz &&\
#     tar -vxzf seqtk-1.3.tar.gz &&\
#     cd seqtk-1.3 &&\
#     make install

# # FastQC
# # ============================================================= 
# RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip -O fastqc_v0.11.8.zip &&\
#     unzip fastqc_v0.11.8.zip &&\
#     cd FastQC/ &&\
#     chmod 755 fastqc &&\
#     ln -s /opt/FastQC/fastqc /usr/local/bin

# # Cutadapt
# # ============================================================= 
# RUN python3 -m pip install cutadapt==2.3

# # STAR aligner
# # ============================================================= 
# RUN wget https://github.com/alexdobin/STAR/archive/2.7.0f.tar.gz -O STAR-2.7.0f.tar.gz &&\
#     tar -xzf STAR-2.7.0f.tar.gz &&\
#     cd STAR-2.7.0f/source &&\
#     make STAR &&\
#     ln -s /opt/STAR-2.7.0f/bin/Linux_x86_64/STAR /usr/local/bin

# # STAR-Fusion
# # ============================================================= 
# RUN wget https://github.com/STAR-Fusion/STAR-Fusion/releases/download/STAR-Fusion-v1.8.1/STAR-Fusion-v1.8.1.FULL.tar.gz -O STAR-fusion-v1.8.1.tar.gz &&\
#     tar -xzf STAR-fusion-v1.8.1.tar.gz &&\
#     cd STAR-Fusion-v1.8.1 &&\
#     make &&\
#     ln -s STAR-Fusion /usr/local/bin

# # Samtools
# # ============================================================= 
# RUN apt-get update &&\
#     apt-get install -y \
#                        gcc \
#                        libbz2-dev \
#                        zlib1g-dev \
#                        libncurses5-dev \
#                        libncursesw5-dev \
#                        liblzma-dev &&\
#     wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 -O samtools-1.9.tar.bz2 &&\
#     tar -xjf samtools-1.9.tar.bz2 &&\
#     cd samtools-1.9 &&\
#     ./configure &&\
#     make install

# # Rseqc
# # ============================================================= 
# RUN python3 -m pip install cython==0.29.14
# RUN python3 -m pip install rseqc==3.0.1

# # Multiqc
# # ============================================================= 
# RUN python3 -m pip install multiqc==1.6
# # For multiqc language support:
# ENV LC_ALL C.UTF-8
# ENV LANG C.UTF-8

# Cleanup and prepare working environment
# ============================================================= 

# Initialize Vagrant provisions
RUN mkdir -p /opt/git &&\
    cd /opt/git &&\
    git clone https://github.com/jjlinscientist/Vagrant &&\
    chmod 755 /opt/git/Vagrant/provisions/* &&\
    cd /opt/git/Vagrant/provisions/ &&\
    ./00_ubuntu_bootstrap_use_sudo.sh &&\
    ./01_nvim_bootstrap.sh &&\
    ./02_get_nvim_deps.sh &&\
    ./03_get_personal_config.sh 

# For nvim HOME and END key function
ENV TERM screen-256color

# Copy resources 
COPY logoplotFastqs/ /opt/git/logoplotFastqs

# Cleanup apt cache
RUN apt-get clean autoclean && apt-get autoremove -y &&\
    mkdir /project

# Start working
WORKDIR /project
