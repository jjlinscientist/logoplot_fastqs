mkdir data/chimerdb
wget https://www.kobic.re.kr/chimerdb_mirror/downloads?name=ChimerDB4.0_sequence.txt.gz \
  -O data/chimerdb/sequence.txt.gz
wget https://www.kobic.re.kr/chimerdb_mirror/downloads?name=Recurrent_table.xlsx \
  -O data/chimerdb/table.xlsx
wget https://www.kobic.re.kr/chimerdb_mirror/downloads?name=ChimerSeqV41.sql \
  -O data/chimerdb/sequence.sql

gunzip data/chimerdb/sequence.txt.gz
