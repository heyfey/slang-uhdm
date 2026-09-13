#!/usr/bin/env python3
"""predict.py <corpus-root>... -- the A-PRIORI mover predictor for r11u12.

§ castElabFoldTargetKinds moves exactly the parameters whose initializer is an
explicit CAST whose TARGET TYPESPEC is not one of the six kinds the producer's
`reduceExpr` vpiCastOp arm reduces (int / longint / shortint / integer / bit /
enum).  Read off the SOURCES alone, before any patched binary runs:

  * a KEYWORD cast to `byte` / `time` / `logic` / `reg` / `real` / `shortreal`
    / `realtime` / `string`  -- the producer's arm has no case for these;
  * a NAMED-TYPE cast `T'(...)` where `T` is a typedef in the same test whose
    target is a packed STRUCT, a packed UNION, a vector or a packed array.

A named cast to an `enum` typedef, to a typedef of `int`/`longint`/`shortint`/
`integer`/`bit`, a KEYWORD cast to those five, and a SIZE cast `N'(v)` all keep
folding and are NOT predicted.

Two controls, both printed:
  NEG -- every folding cast form found (must stay OFF the mover list);
  POS -- the three brief rows (def_ctx_struct_param, latch_decoder_partial,
         latch_tlb_napot) must appear, or the scan is broken.
"""
import os
import re
import sys

FOLD_KW = {'int', 'longint', 'shortint', 'integer', 'bit'}
NOFOLD_KW = {'byte', 'time', 'logic', 'reg', 'real', 'shortreal', 'realtime',
             'string'}
# typedef <base...> NAME ;   (one line or a struct/union block)
TD_SIMPLE = re.compile(r'\btypedef\s+([A-Za-z_][\w:$.\[\]\s\'+\-*/]*?)\s+'
                       r'([A-Za-z_]\w*)\s*(?:\[[^;]*\])?\s*;')
TD_BLOCK = re.compile(r'\btypedef\s+(struct|union|enum)\b')
CAST = re.compile(r"(?<![\w'])([A-Za-z_]\w*)\s*'\s*\(")
PARAM = re.compile(r'\b(?:localparam|parameter)\b')


def typedefs(text):
    """name -> one of struct/union/enum/vector/atom<kind>/other."""
    out = {}
    # block typedefs: typedef struct|union|enum ... } NAME;
    for m in re.finditer(r'\btypedef\s+(struct|union|enum)\b', text):
        # find the matching `}` then the name
        i = text.find('}', m.end())
        if i < 0:
            continue
        m2 = re.match(r'\s*(?:\[[^\]]*\]\s*)*([A-Za-z_]\w*)', text[i + 1:])
        if m2:
            out[m2.group(1)] = m.group(1)
    for m in TD_SIMPLE.finditer(text):
        base, name = m.group(1).strip(), m.group(2)
        if name in out:
            continue
        w = base.split()[0]
        if w in ('struct', 'union', 'enum'):
            continue
        if w in FOLD_KW:
            out[name] = 'atomfold'
        elif w in NOFOLD_KW or '[' in base:
            out[name] = 'vector'
        else:
            out[name] = 'alias:' + w
    return out


def scan(root):
    rows = []
    for d in sorted(os.listdir(root)):
        td = os.path.join(root, d)
        if not os.path.isdir(td):
            continue
        text = ''
        for dp, _, fns in os.walk(td):
            for fn in fns:
                if fn.endswith(('.sv', '.svh', '.v', '.vh')):
                    try:
                        text += open(os.path.join(dp, fn), encoding='utf-8',
                                     errors='replace').read() + '\n'
                    except OSError:
                        pass
        if not text:
            continue
        tds = typedefs(text)
        # resolve alias chains
        for _ in range(8):
            for k, v in list(tds.items()):
                if v.startswith('alias:'):
                    tds[k] = tds.get(v[6:], 'other')
        hits, negs = set(), set()
        for line in text.split('\n'):
            if not PARAM.search(line):
                continue
            for m in CAST.finditer(line):
                t = m.group(1)
                if t in FOLD_KW:
                    negs.add(t)
                elif t in NOFOLD_KW:
                    hits.add(t)
                elif t in tds:
                    k = tds[t]
                    if k in ('struct', 'union', 'vector'):
                        hits.add(t + ':' + k)
                    else:
                        negs.add(t + ':' + k)
                else:
                    negs.add(t + ':size-or-param')
        if hits:
            rows.append((d, sorted(hits), sorted(negs)))
    return rows


def main():
    pos = {'def_ctx_struct_param', 'latch_decoder_partial', 'latch_tlb_napot'}
    seen = set()
    for root in sys.argv[1:]:
        print('##', root)
        for d, hits, negs in scan(root):
            seen.add(d)
            print('  PREDICT %-42s %s   NEG=%s' % (d, ','.join(hits),
                                                   ','.join(negs) or '-'))
    miss = pos - seen
    print('POSITIVE CONTROL:', 'PASS' if not miss else 'FAIL missing ' + str(miss))


main()
