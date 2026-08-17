# r10vrgg4 — ADVERSARIAL VERIFICATION of r10rgg4 (§ sizeDimOvrChain4)

VERDICT: **ACCEPT the patch. REJECT three clauses of the stated law and one
gate NUMBER.**  Nothing is pristine-right -> patched-wrong, so nothing was
fixed; the shipped surface is byte-for-byte the implementer's.

Base f65aff5.  Worktrees /tmp/wt_vrgg4 (patched) + /tmp/wt_vrgg4pris (pristine),
both fresh `git worktree add ... f65aff5`.  Binaries built here, -j 2:
  pristine  e7d7538aeba7a67462a4b050c9e97ad7
  patched   3bdde2e3ef868e6b5b50ca8607ae77ab
Both md5s equal the implementer's, so every number below was taken on the same
bytes their report was taken on.

## 1. Headline numbers, all reproduced independently

| claim | mine | verdict |
|---|---|---|
| patch sha256 263a5f03…, applies clean on FRESH f65aff5 | same | OK |
| grid 78 cells FIXED=43 BROKEN=0 STILL=26 OK=1653 MISS=0 | identical; SCORE.txt byte-identical | OK |
| goldens 23/0, `/bin/false` 0/23 | 23/0, 0/23 | OK |
| u2r both modes 679/50/2; 0 rows base-vs-pat; 0 rows vs committed gate | identical, dump histos 52/187/492 and 52/183/496 | OK |
| surelog both modes; 0 rows base-vs-pat; 0 rows vs golden_surelog.csv | identical, all status histos identical | OK |
| byteverify u2r 0/1358, SELFCHECK 1357, SELFCHECK1 exactly 1 | identical | OK |
| Rggen mover = 18 line-sides, the two u_adapter_common size constants | identical, 1,583,001-line dump | OK |
| rggencensus 6/6 elab iface_array bounds to golden (deficit 2 -> 0) | identical | OK |
| canaries ok=52/0 (sl) and ok=16/0 (u2r); 3 byte-identical canaries; pins SVSwitch 4842211c4030 / YosysVerx 6ccda350c24a | identical, both pins exact | OK |
| head: Rggen default 50 cmp lines / 1 head -> 64 / 1; new head the 400-bit SUB_N_LIST constant @64:58-64:68 | identical | OK |
| ladder 63 -> 61 FIXPOINT, census identical except constant\|VpiSize\|INT:G>O 2 -> 0 | identical | OK |
| boundaries rgg3 (37 arms) MOVED=0; vrgg3 52 cells 0 DIFFERS; earl49/51/52/55 47 sources MOVED=0 | identical (vrgg3: 25 EQ / 25 NEQ / 2 NO_DB) | OK |

## 2. The one gate number that is WRONG (and why it is not the patch)

Gate 5 / surelog reports **1 mover**.  I measure **2**:

    MOVER ./default/Rggen-50ccbd70/slang.uhdm       (real, the § site, to golden)
    MOVER ./default/Scoreboard-59431470/slang.uhdm  patched=255734a08319 pristine=498d99eea945

Scoreboard is **emitter nondeterminism, proven**: the PRISTINE binary run four
times on Scoreboard's own command line produced BOTH md5s (498d99eea945 x2,
255734a08319 x2) and the PATCHED binary also produced both.  The delta is a
23-object block of `svunit_pkg::` task/function objects relocating inside the
weakly-referenced tail — 46 `<` / 46 `>` lines, dump line count identical at
1,098,516 on both sides.  So "MOVERS: 1/955" is a coin that landed the same way
twice, not a measurement; the reportable figure is **1 attributable mover + 1
known-nondeterministic row**, and SELFCHECK1 is 2-or-3 accordingly.

## 3. What the implementer did NOT run (and it favours them)

`r10rgg3repro/boundary.sh` over EVERY committed probe arm was never taken:

    ARMS=1112  MOVED=1  NO-DATABASE=12

The single mover is `r10rggen7repro/t4.sv` — `t4_child #(N)` positional paramref
on an iface-array port `[N]`, i.e. the § site — and it **CONVERTS the arm**:
base official uhdm-cmp NOTEQUAL (50 cmp lines / 1 head) -> patched **CMP_EQUAL,
0 lines**.  All 12 NO-DATABASE arms were re-run individually: both binaries fail
identically, pre-existing.

## 4. The adversarial grid: 69 cells, BROKEN=0

`gen_vgrid.py` / `gen_vgrid2.py` (61 measured field cells) + `gen_vgrid3.py`
(8 reach cells, byte-compared).  Two independent judges:

    score.py (field grid)   FIXED=28  BROKEN=0  STILL=20  OK=1044/1653
    cmpjudge.sh (OFFICIAL uhdm-cmp, golden=LHS, per cell)
        5 cells NOTEQ -> EQUAL   (v5c time, v5g/h/i/j unsigned predef ints)
        0 cells EQUAL -> NOTEQ
    gen_vgrid3 reach cells    8/8 BASE and PAT dumps BYTE-IDENTICAL

Also re-scored the implementer's own 78 cells with FULL-SPAN site keys instead of
their start-line normalisation: FIXED=43 BROKEN=0 STILL=26 unchanged, 816 MISS —
and every one of the 816 is the DEF-view `array_typespec` span column with BASE
== PAT.  Their normalisation masks nothing.

## 5. Three clauses of the law are REFUTED by measurement

R-A (worst).  "a SIGNED arithmetic operator -> 64 INT ... the arm consults
slang's own result signedness".  The distinguisher is the OPERATOR, and `+` is
UINT in golden regardless of signedness:

    #(.R(4+2))       pure literals  golden 64 UINT:6   ours 64 INT:6   v7d
    #(.R(P+2))       P int param    golden 64 UINT:6   ours 64 INT:6   v7a
    #(.R(R+2))       R lit-ovr int  golden 64 UINT:6   ours 64 INT:6   v7b, v4b
    #(.R(LP+2))      localparam     golden 64 UINT:6   ours 64 INT:6   v7c
    #(.R(pk::PR+2))  pkg param      golden 64 UINT:6   ours 64 INT:6   v7e
    #(.R(P*2))       (control)      golden 64 INT:6    ours 64 INT:6   v7g OK

`4+2` is the killer: no unsigned operand exists anywhere, slang says signed,
golden says UINT.  The grid's `(3>1)+5` fitted the signedness story by accident.

R-B.  "-> 64" is not a constant.  With a PARAMETER operand the same shapes read
32:  `-(-P)` golden sz=32 (v7h), `(1)?P:0` golden sz=32 (v7k); ours 64 in both.
With literal operands (arm hb/ha) the same shapes really are 64.

R-C.  "the type link is attached for plain signed `int` ONLY".  Golden also
attaches an `int_typespec` for every SIGNED VECTOR type:
`bit signed [7:0]` (v5b), `logic signed [7:0]` (v5l), `signed [7:0]` (v5m) — all
golden ts=Y, ours ts=N.  The measured gate over 23 declared types is
**Y iff the parameter has an EXPLICIT declared type that is SIGNED and is not one
of integer/longint/shortint/byte/time** (open exception: an enum-typed param
reads N although its base type is signed, v5d).
The NARROWING itself is still a strict improvement: I closed the
predefined-integer space exhaustively (`integer unsigned`, `longint unsigned`,
`shortint unsigned`, `byte unsigned`, `int signed`, `time`) and NONE is a
golden-Y that the patch turns off.  It is the WRITTEN LAW that is wrong, not the
code.

## 6. Ranked residues (each measured here, none of them a regression)

1. R-A `+` reads UINT — 6 cells; the widest wrong clause, and the one most
   likely to bite the next pass in this family.
2. The **Synth path writes `foldVal`** (the elaborated element count) where
   golden writes the OVERRIDE EXPRESSION's own value.  They differ exactly when
   the leaf's declared type truncates: `bit [1:0] R` fed `bit [2:0] P = 6`
   (2 elements) -> golden `sz=3 UINT:6`, ours `sz=3 UINT:2` (v1d); `#(.R(3*2))`
   -> golden `sz=64 INT:6`, ours `sz=64 INT:2` (v1f).  BASE was equally wrong
   (`sz=2 UINT:2`), so the patch fixes the size and inherits the value error.
   The Verbatim path is right for the same reason it copies the literal: golden
   really does print 12 for `bit [2:0] R` fed `#(.R(12))` on a 4-element array
   (v1a, all three sides agree).
3. **`defparam` never fires the law** — slang's `isOverridden()` is false for a
   defparam route, so `ovrChain4` is false: v2a golden 64 UINT ts=N, ours
   32 UINT ts=Y (base identical).  The law says "override-expression reducer";
   Surelog reduces the defparam route the same way and we skip it.
4. **Reach hole on an `interface_inst` parent** — an interface whose own port is
   an iface array `[R]` with R overridden: golden has
   `work@top.u|interface_array … sz=64 UINT:6 ts=N`, and BOTH binaries emit NO
   SUCH OBJECT AT ALL (w5_iface_port).  A missing-object residue the § can never
   reach.
5. Cast shapes: `signed'(6)` golden INT, ours UINT (v6e); `8'(6)` golden sz=8,
   ours 64 (v6f).  The "explicit cast -> 64 UINT" clause ignores the cast type.
6. `{1{3'b110}}` -> golden `sz=3 BIN:110`, ours **`INT:-2`** — a wrong VALUE:
   the Verbatim path hands `emitSyntaxExpr` a replication that folds the signed
   3-bit 110 to -2 (v6i).  Base identical, so pre-existing.
7. Golden's own oddity, recorded so nobody chases it: `$bits(logic [5:0])` as
   the override reads golden `UINT:1` (v6d).
8. slang REJECTS `#(.R(top.TLP))` and `#(.R(arr[0].W))` ("hierarchical name in a
   constant expression"), which Surelog accepts — v4c/v4d, NO_DATABASE on both
   binaries, out of this family.

## 7. Ops notes

* Every sweep's `cmds.txt` was audited: exactly one binary path per workdir,
  `/tmp/vrgg4_{base,pat}_bin`.  No stale-binary reading.
* My wave-1 `v6g`/`v6h` cells were arithmetically bad SV (`{2{3'b011}}` = 27 for
  a 6-element array; `'1` = -1) and slang rejects them on BOTH binaries; they are
  kept, labelled, and re-done correctly as `v6i`/`v6j`/`v6k`.  A cell that
  measures nothing must not read as agreement.
* `run_grid.sh` + `score.py` + `byteverify.sh` + `ct8rows.sh` + `rggencensus.sh`
  are the implementer's, carried in verbatim so the two reports are comparable;
  `cmpjudge.sh` is r10vrgg3repro's official-cmp runner; `score_fullspan.py` is
  `score.py` with the key normalisation removed, to audit it.
