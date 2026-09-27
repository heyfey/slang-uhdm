#!/bin/bash
# r11u183: per-switch census of one UVM row (the map-9 analyzer on one database), BIN=<law binary>; uses drivers/mkrow.sh
# per-switch census of one UVM row: law3 with one switch set; prints the chosen census keys for that row
t=$1; sw=$2; tag=${sw:-NONE}
cd /tmp/r11u183_W2 && . /tmp/wt_r11u183/tools/probe/r11u183dec/drivers/env.sh
D=/tmp/r11u183_W2/sw/$t.$tag; mkdir -p $D
/tmp/wt_r11u183/tools/probe/r11u183dec/drivers/mkrow.sh $t ${BIN:-$B/slang-uhdm.lawJ} $tag.$$ ${sw:+$sw=1} > $D/jobs.tsv
export SCMP=/tmp/r11u183_bin/strictcmp_x R11U138_TMP=$D/tmp; mkdir -p $D/tmp
DR=/tmp/wt_r11u183/tools/probe/r11u179map/drivers
awk -F'\t' '{print $1,$2,$3,$4,$5}' $D/jobs.tsv | DUMPS=$D/dumps xargs -n5 $DR/run1.sh
python3 $DR/analyze.py $D/jobs.tsv $D/corpus.jsonl $D/dumps 1 > $D/an.log 2>&1
rm -f $(cut -f5 $D/jobs.tsv) $D/dumps/*/*/*.a $D/dumps/*/*/*.b
python3 - $D/corpus.jsonl "$t" "$tag" <<'PY'
import json,sys,collections
c=collections.Counter()
for l in open(sys.argv[1]):
    r=json.loads(l)
    for f in r['rows']:
        c[f['cluster']]+= f.get('nobj',1) if f['facet']=='struct' else 1
K=['span|bit_typespec|line+col+endline+endcol|under:ref_typespec','span|int_typespec|line+col+endline+endcol|under:ref_typespec','name|bit_typespec|tok:id::->|under:ref_typespec','span|class_typespec|endcol|under:ref_typespec','fullname|ref_typespec|tok:id::id::id::id::->id@id.|under:enum_typespec','fullname|ref_typespec|tok:id::id::id::id::->id.id::id.id.|under:bit_typespec']
print(sys.argv[2], sys.argv[3], 'total', sum(c.values()), ' '.join(f'{k.split("|")[0]}/{k.split("|")[1]}/{k.split("|")[2][:12]}:{c[k]}' for k in K))
PY
