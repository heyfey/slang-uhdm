#!/usr/bin/env python3
# r10sd4 tap — records the OWNER of every `->Instance(...)` SETTER call.
#
# r10sd3's tap wrapped the ARGUMENT (`X->Instance(sd3tap(F,L,ARG))`), which
# answers "which site stamps a class_defn".  This pass needs the opposite
# question — "which site stamps THIS typespec" — so the wrapper has to see X.
# X is recovered by scanning BACKWARD from `->Instance(` over a balanced
# postfix expression (identifier chars, `::`, `.`, `->`, and balanced `()`/`[]`),
# which covers every shape in this tree: bare identifiers (`ic9`), C-style casts
# (`((UHDM::typespec*)ts)`) and accessor chains
# (`tm->Typespec()->Actual_typespec()`).
#
#     EXPR->Instance(ARG)  ->  sd4own(__FILE__,__LINE__,EXPR)->Instance(ARG)
#
# Getters (`->Instance()`) are skipped by the `)`-lookahead, exactly as sd3's
# tap does.  DEBUG ARTIFACT — never built into a binary that produces a measured
# artifact, and not in the delivered patch.
import os, sys
root = sys.argv[1]
IDCH = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_:.")
def back(txt, j):
    # j is the index of '-' in '->Instance('
    p = j
    depth = 0
    while p > 0:
        c = txt[p-1]
        if c in ')]':
            depth += 1; p -= 1; continue
        if c in '([':
            if depth == 0: break
            depth -= 1; p -= 1; continue
        if depth > 0:
            p -= 1; continue
        if c in IDCH:
            p -= 1; continue
        if c == '>' and p >= 2 and txt[p-2] == '-':
            p -= 2; continue
        break
    return p
files = [os.path.join(root,'src',f) for f in sorted(os.listdir(os.path.join(root,'src'))) if f.endswith('.cpp')]
total = 0
for path in files:
    txt = open(path).read(); out = []; i = 0; n = 0
    while True:
        j = txt.find('->Instance(', i)
        if j < 0:
            out.append(txt[i:]); break
        k = j + len('->Instance(')
        if txt[k] == ')':
            out.append(txt[i:k]); i = k; continue
        s = back(txt, j)
        if s >= j:
            out.append(txt[i:k]); i = k; continue
        out.append(txt[i:s])
        out.append('sd4own(__FILE__,__LINE__,' + txt[s:j] + ')')
        out.append(txt[j:k])
        i = k; n += 1
    if n:
        open(path,'w').write(''.join(out)); total += n
        print(f'{os.path.basename(path)}: {n}')
print('TOTAL wrapped:', total)
