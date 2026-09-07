#!/usr/bin/env python3
"""r10uvm192repro/score192.py — THE VERDICT ON THE CALL-BINDING CENSUS.

MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS is ALWAYS golden.

Two jobs, over the `<mode>.<test>.g` / `.o` census pairs `cen192.sh` writes:

1. THE PREDICTION SCORE.  Every `PRED ... MOVE` row is a cell the law will
   re-point.  For each one, look up GOLDEN's binding for the SAME call (keyed
   on span x call kind x written name x caller scope x listing size) and say
   whether the move lands ON golden's face (TO-GOLDEN), lands somewhere else
   while golden already agreed with us (AWAY-GOLDEN), or lands somewhere else
   while we were already wrong (STILL-WRONG).  A `WIDE-NO-ENTRY` row that
   golden nonetheless binds to a package entry is reported as MISSED.

2. THE WHOLE-CALL JOIN.  Every CALL cell of both databases as a MULTISET
   (keys collide; a dict would drop rows), giving AGREE / one-sided-golden /
   one-sided-ours before and after.  Run it with `--ours2 <dir>` to score the
   PATCHED census against the same golden and get the before/after pair.

   usage: score192.py <pristine census dir> [--ours2 <patched census dir>]
"""
import collections
import os
import sys


def load(path):
    calls = collections.Counter()
    preds = []
    with open(path, encoding='utf-8', errors='replace') as fh:
        for ln in fh:
            f = ln.rstrip('\n').split('\t')
            if f[0] == 'CALL' and len(f) >= 10:
                # key = span, kind, name, caller-scope kind, caller-scope name,
                #       enclosing-sub kind, top-listing size ; payload = bound face
                key = (f[2], f[3], f[4], f[5], f[6], f[7], f[9])
                calls[(key, f[8])] += 1
            elif f[0] == 'PRED' and len(f) >= 9:
                preds.append(f)
    return calls, preds


def goldenface(gcalls, key):
    """Every face golden carries under this key (a multiset, so ambiguity shows)."""
    return sorted(p for (k, p), n in gcalls.items() if k == key for _ in range(n))


def pairs(d):
    for fn in sorted(os.listdir(d)):
        if fn.endswith('.g'):
            yield fn[:-2], os.path.join(d, fn), os.path.join(d, fn[:-2] + '.o')


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 2
    base = args[0]
    ours2 = None
    if '--ours2' in args:
        ours2 = args[args.index('--ours2') + 1]

    tot = collections.Counter()
    for row, gp, op in pairs(base):
        gcalls, _ = load(gp)
        ocalls, opreds = load(op)
        # --- 1. the prediction score -----------------------------------
        verdicts = collections.Counter()
        detail = []
        for f in opreds:
            # PRED row: 0 tag(1) verdict(2) then the CALL's OWN KEY in fields
            # 3..9, then pkg= home= from= to=
            kind = f[2]
            key = (f[3], f[4], f[5], f[6], f[7], f[8], f[9])
            pkg, home = f[10][4:], f[11][5:]
            frm, to = f[12][5:], f[13][3:]
            gfaces = goldenface(gcalls, key)
            if kind == 'MOVE':
                if gfaces and set(gfaces) == {to}:
                    verdicts['TO-GOLDEN'] += 1
                elif gfaces and set(gfaces) == {frm}:
                    verdicts['AWAY-GOLDEN'] += 1
                    detail.append(('AWAY', key[0], key[2], pkg, home, frm, to, gfaces))
                else:
                    verdicts['STILL-WRONG'] += 1
                    detail.append(('STILL-WRONG', key[0], key[2], pkg, home, frm, to, gfaces))
            else:
                if gfaces and set(gfaces) != {frm}:
                    verdicts['MISSED'] += 1
                    detail.append(('MISSED', key[0], key[2], pkg, home, frm, to, gfaces))
                else:
                    verdicts['WIDE-CORRECTLY-STILL'] += 1
        # --- 2. the whole-call join ------------------------------------
        agree = sum((gcalls & ocalls).values())
        og = sum((gcalls - ocalls).values())
        oo = sum((ocalls - gcalls).values())
        line = (f"{row:34s} PRED " +
                " ".join(f"{k}={v}" for k, v in sorted(verdicts.items())) +
                f" | JOIN agree={agree} golden-only={og} ours-only={oo}")
        if ours2:
            o2 = os.path.join(ours2, os.path.basename(op))
            if os.path.exists(o2):
                o2c, o2p = load(o2)
                a2 = sum((gcalls & o2c).values())
                g2 = sum((gcalls - o2c).values())
                u2 = sum((o2c - gcalls).values())
                line += (f"\n{'':34s} AFTER agree={a2} golden-only={g2}"
                         f" ours-only={u2}  (moves-left={sum(1 for p in o2p if p[2]=='MOVE')})")
                tot['after-agree'] += a2
                tot['after-golden-only'] += g2
                tot['after-ours-only'] += u2
        print(line)
        for d in detail:
            print(f"{'':36s} {d[0]} @{d[1]} {d[2]} pkg={d[3]} home={d[4]}\n"
                  f"{'':40s} from={d[5]}\n{'':40s} to  ={d[6]}\n{'':40s} gold={d[7]}")
        for k, v in verdicts.items():
            tot[k] += v
        tot['before-agree'] += agree
        tot['before-golden-only'] += og
        tot['before-ours-only'] += oo
    print("-- TOTALS " + " ".join(f"{k}={v}" for k, v in sorted(tot.items())))
    bad = tot['AWAY-GOLDEN'] + tot['STILL-WRONG']
    print(f"-- VERDICT: {'PASS' if bad == 0 else 'FAIL'}  "
          f"TO-GOLDEN={tot['TO-GOLDEN']} AWAY-GOLDEN={tot['AWAY-GOLDEN']} "
          f"MOVED-WRONG={tot['STILL-WRONG']} MISSED={tot['MISSED']}")
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
