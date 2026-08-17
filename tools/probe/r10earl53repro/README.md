# r10earl53 — § connPathRootTs53

**Earlgrey_0_1/default's head CLEARED: the missing `ref_typespec` is gone, and
with it 5 555 of them across the design — 5 408 landing exactly on golden,
0 moving away, 0 extra, 0 with the wrong `vpiActual`, and the DEF view
byte-identical.**

---

## THE HEAD (R0 of this pass)

```
LHS(golden): ref_typespec: (work@top_earlgrey.u_rv_core_ibex.fifo_i.reqfifo
                            .wdata.tl_h_i.a_opcode)
             |vpiParent: hier_path (tl_h_i.a_opcode)  38:22-38:37
             |vpiActual: struct_typespec (tlul_pkg::tl_h2d_t)  32:11-61:31
RHS(ours)  : <null>
```

`hw/…/tlul_fifo_sync.sv:32-46` — a concat port connection:

```systemverilog
prim_fifo_sync #(...) reqfifo (
  .wdata ({tl_h_i.a_opcode ,
           tl_h_i.a_param  , ... }),
```

## THE ONE MEASUREMENT THE WHOLE PASS TURNS ON

`hpcensus53.py` streams a dump and reports every hier_path FULL PRINT with the
field it hangs on, its enclosing kind, its `vpiExpr` and its `vpiTypespec`.
Run over golden's Earlgrey elab dump it splits 14 478 hier_paths like this:

```
HANGS-ON       PARENT-KIND     vpiExpr-KIND   TS?    N
vpiOperand     operation       struct_var     TS     3281
vpiOperand     operation       -              no-TS  2642
vpiHighConn    port            struct_var     TS     2587
vpiHighConn    port            -              no-TS  2303
vpiLhs         cont_assign     -              no-TS  1149
vpiRhs         cont_assign     -              no-TS   879
vpiHighConn    port            struct_net     TS      625
vpiPattern     tagged_pattern  array_var      TS      261
...
```

Context is **not** the discriminator — `vpiOperand/operation` and
`vpiHighConn/port` each appear in BOTH columns. Deepening the ancestor chain
splits them in one line:

```
TS     vpiModule:module_inst/vpiPort:port/vpiHighConn:operation            3096
TS     vpiModule:module_inst/vpiModule:module_inst/vpiPort:port            3005
no-TS  uhdmallModules:module_inst/vpiRefModule:ref_module/vpiPort:port     2276
no-TS  vpiGenScopeArray/vpiGenScope/vpiContAssign:cont_assign              1464
no-TS  vpiContAssign:cont_assign/vpiRhs:operation/vpiOperand:operation      888
```

**The ELABORATED port connection takes it; the DEF listing's `ref_module`
connection and every cont-assign / procedural context does not.**

## THE LAW

> **§ connPathRootTs53 — a connection actual's hier_paths take the ROOT
> object's typespec.** In the ELABORATED view, EVERY `hier_path` inside a port
> connection actual — the actual itself, a concat operand, an operand nested
> any number of operations deep — carries
> * `vpiTypespec` → a `ref_typespec` whose `vpiActual` is the typespec of the
>   path's **ROOT** object (`tl_h_i.a_opcode` → `tlul_pkg::tl_h2d_t`, the base
>   struct, **never** the member's own type) and whose `vpiFullName` is
>   `<child instance path>.<formal>.<the path's written text>`; and
> * `vpiExpr` (`Root_value`) → the PARENT instance's net/var for that root.
>
> The DEF listing's `ref_module` connections carry neither.

We already implemented ONE special case of this — a **one-level** member access
that IS the actual — and nothing else. The corpus join says how much that
missed: of 13 774 hier_paths present on both sides, **5 408 had golden's
typespec and not ours**, split `vpiOperand` 3 284 / `vpiHighConn` 2 124.

## WHAT uhdm-cmp ACTUALLY READS — and why the head is only the typespec

```
hier_path::Compare = basetype(expr) + Path_elems + Root_value + VpiName
expr::Compare      = VpiDecompile + VpiSize + Typespec
ref_typespec::Compare = VpiName + VpiDefName + Actual_typespec
ref_obj::Compare      = VpiType + VpiName + VpiDefName + VpiGeneric
                        + Actual_group + VpiStructMember
```

`ref_obj::Compare` does **not** read `VpiFullName`, so the path elements'
elaborated names — which this site also rewrites — are invisible to the head.
The ONE cmp-visible field in this whole family is `expr::Compare`'s
`Typespec()`. That is why a 5 408-object gap presented as a single `<null>`.

## THE GRID — golden vs pristine vs patched, `grid53.sh a1`

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| `u_one` | `t_i.v` | `struct top_t` | `struct top_t` | `struct top_t` |
| `u_two` | `t_i.o.w` | `struct top_t` | — | **`struct top_t`** |
| `u_three` | `t_i.o.i.op` | `struct top_t` | — | **`struct top_t`** |
| `u_uni` | `u_i.a` | **`union uni_t`** | `union uni_t` | `union uni_t` |
| `u_anon` | `anon_i.m` | `struct_typespec()` | — | — (**R1**) |
| `u_arr` | `ea_i[1].e0` | **none** | none | none |
| `u_cat` ×3 | concat operands | `struct top_t` | — | **`struct top_t`** |
| `u_ncat` ×4 | NESTED concat | `struct top_t` | — | **`struct top_t`** |
| `u_rep` | `{2{t_i.o.i.op}}` | `struct top_t` | — | **`struct top_t`** |
| `u_bin` ×2 | `a & a` | `struct top_t` | — | **`struct top_t`** |
| `u_ter` ×2 | `c ? a : 0` | `struct top_t` | — | **`struct top_t`** |
| cont_assign / always / bare operand | same paths | none | none | none |
| every `|d|` (DEF-view) row | | none | none | none |

`a2` closes the rest:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| `u_pa` | `ha_i.pa[1].e0` (MID-PATH select) | `struct hasarr_t` | — | **`struct hasarr_t`** |
| `u_ua` | `ua_i[1].e0` (typedef'd UNPACKED array root) | **`array_typespec uarr_t`** | — | — (**R2**) |
| `u_lv` / `u_ln` | local struct VAR / NET root | `struct el_t` | `struct el_t` | `struct el_t` |
| `u_out` | output direction, both sides | `struct el_t` | `struct el_t` | `struct el_t` |
| `u_ar[0..1]` | instance ARRAY | `struct el_t` | `struct el_t` | `struct el_t` |
| `g_if.u_gs` | inside a generate scope | `struct el_t` | — | **`struct el_t`** |
| `u_mid` | `itf_i.mp` (INTERFACE port) | none | none | none |

### TWO DESIGN DECISIONS, BOTH MEASURED, ONE OF THEM A REFUTED FENCE

**The root is resolved BY NAME, not by pairing operands.** The rule needs the
slang symbol behind a UHDM hier_path nested inside a concat / replication /
binary / ternary. Pairing UHDM operands with slang sub-expressions positionally
lines up for a concat and does not for a replication (`{count, concat}`) or a
ternary, and a mis-pairing does not fail loudly — it binds the path to the
WRONG struct's typespec, which `ref_typespec::Compare` reads. So the rule builds
a `{name → ValueSymbol}` map from the connection expression's own
`NamedValueExpression`s and looks up the path's first component. It cannot
mis-pair; the only thing it can do is decline, and an ambiguous name is dropped
outright.

**There is NO typespec-KIND fence, and the one I wrote first was refuted before
it landed.** The Earlgrey census shows `struct_typespec` in 6 707 of 6 968
golden cells and `array_typespec` in the other 261 — all of the latter in the
`tagged_pattern` family — so a "struct only" fence looked free. `a1`'s `u_uni`
killed half of it (golden attaches `union_typespec`) and `a2`'s `u_ua` killed
the rest: a **typedef'd** unpacked array root takes `array_typespec` in golden.
The real fence is the `typedefTs` lookup itself — `a1`'s `u_arr`, an
**anonymous** unpacked array root (`el_t ea_i [0:1]`), gets no typespec in
golden and misses in `typedefTs` for the same reason.

## THE FENCE A GATE BOUGHT

The rule's first version built the name map — and therefore called
`getDeclaredType()->getType()`, forcing slang's LAZY type resolution — for every
operation-shaped connection actual in a design. The byte verifier reported
Scr1SvTests (a NAMED CANARY, both modes) and Scoreboard as movers. So the rule
now **collects the hier_paths first and returns before touching anything if
there are none**: a connection with no hier_path in it is not read at all.

It did not fix those two, and that is recorded rather than papered over — see
R3.

## RESULT — prediction vs measurement

`CENSUS_PREDICT53.txt` was written from {golden, pristine} while the patched
binary was still linking. Scored:

| prediction | measured | verdict |
|---|---|---|
| MISSING-TS on shared keys 5408 → **0**, EXTRA-TS **0** | 0 and 0 | **HIT** |
| our TS count 949 → **6357** | **6504** | **MISSED by 147** — I forgot the 147 keys whose *path NAME* differs from golden's (gen-scope `[i]` vs `[6]`, a separate standing residue); they gained the typespec too, and golden's counterpart carries the SAME `struct_typespec`, so they moved toward golden as well |
| residual vs golden = the 464 `tagged_pattern` cells | 6968 − 6504 = **464** exactly | **HIT** |
| no cell loses or changes a typespec | ACTUAL-MISMATCH 0, moved-away 0 | **HIT** |
| DEF view: zero movers | DEF md5 `f58a946aba53db953a9a2a41a81a27d8` on BOTH sides | **HIT** |
| a1 `u_anon` and a2 `u_ua` gain the typespec | they do **not** — `typedefTs` has no entry for an anonymous struct or a typedef'd unpacked array | **REFUTED** (R1, R2) |
| corpus rows: 0 differing | 0 over 731 and 0 over 1588 | **HIT** |

Earlgrey census, order-blind, keyed {instance, port, path, span, field}:

```
golden    rows=14478 TS=6968
pristine  rows=14680 TS= 949
patched   rows=14680 TS=6504
shared=13774  MISSING-TS=0  EXTRA-TS=0  ACTUAL-MISMATCH=0
MOVED=5555   toward-golden=5408   away=0   no-golden-key=147
```

Whole-database delta, workdir-normalised, classified as MULTISETS of line texts
by `attr53.py`:

```
diff-lines: -3 +49998 | NET gained=49995 attributed=49995 LOST=0 UNEXPLAINED=0
   5555 x |vpiTypespec:  + \_ref_typespec: + 4 fields   = 38885 lines
   5555 x |vpiExpr:      + \_<var/net>:                 = 11110 lines
```

**Nothing is deleted and nothing else is added.** The three `-` diff lines are
GNU diff re-aligning text it re-adds two lines lower; the multiset check is what
proves that, and building it caught the first version of this verifier calling
those three a LOSS.

### The new head — R0 for r10earl54

Earlgrey_0_1/default now heads at **82 cmp lines / 1 head**, on a DIFFERENT
object and a different family — a REPLICATION FOLD, in the same file:

```
// tlul_fifo_sync.sv:75-76
.wdata ({tl_d_i.d_opcode, ... , {SpareRspW{1'b0}}})

LHS(golden): constant  BIN:0000…0 (32 zeros)  size 32  vpiConstType:3
             |vpiTypespec: ref_typespec -> int_typespec
RHS(ours)  : operation vpiOpType:34 (replication)
                |vpiOperand constant UINT:32
                |vpiOperand operation vpiOpType:33 { 1'b0 }
```

Golden's ExprEval folds a constant-count replication of a constant into ONE
sized binary constant at the port's connection; we keep the written
replication tree. Prior art: § paramInitAdjustSizeElab52's F2, which measured
that a concat/replication **parameter initializer** does NOT take the
`adjustSize` width — this is the same operator in the other position (a port
connection actual), and F2's note says the two disagree, so the fold is
plainly context-dependent and must be measured, not carried over.

## RESIDUES

| id | what | witness | changed here? |
|---|---|---|---|
| **R1** | an **ANONYMOUS** struct root gets no typespec from us; golden emits a nameless `struct_typespec` | `a1` `u_anon` (`anon_i.m`) | no — `typedefTs` is keyed by the TYPEDEF symbol and an inline `struct packed {...}` port has none |
| **R2** | a **typedef'd UNPACKED ARRAY** root gets no typespec from us; golden emits `array_typespec(uarr_t)` | `a2` `u_ua` (`ua_i[1].e0`) | no — same `typedefTs` miss. R1+R2 are ONE unfixed thing: `typedefTs` covers named packed aggregate typedefs and not these two |
| **R3** | **Scr1SvTests** (both modes) moves **227 bytes** with its uhdm **dump BYTE-IDENTICAL**. A temporary trace build showed the rule reaching exactly two connections there — `exu_queue.ialu_cmd` / `exu_queue.lsu_cmd` — which the OLD one-level rule ALREADY covered (the PRISTINE dump carries both `ref_typespec`s). What is left is `conn.visit(...)` forcing slang's lazy resolution earlier, which reorders two objects in the serialised arena. `cmp -l` shows the delta as index values swapping by ±1, the file SIZE is unchanged, and the CSV row is byte-identical to the committed baseline | byte verifier + `cmp -l` + dump `diff -q` | no |
| **R4** | **golden's `vpiExpr` is NOT coupled to its typespec.** `a1` `u_arr` (`ea_i[1].e0`) has golden `vpiExpr: array_net(ea_i)` and NO typespec; we emit neither. The Earlgrey correlation (TS ⟺ vpiExpr, 6968/6968) is a coincidence of that design's roots all being typedef'd structs, and reading it as the law would have been wrong | `a1` `u_arr` | no |
| **R5** | the 464 `vpiPattern/tagged_pattern` hier_paths carry a typespec in golden (203 struct + 261 array) and none in ours, and our emitter hangs them on `vpiOperand:operation` so they do not even share a census key. A DIFFERENT context; the next-largest block of this family | Earlgrey census | no |
| **R6** | the 147 gen-scope cells whose path NAME is `…q[i]` for us and `…q[6]` for golden (index not folded into the hier_path name) — pre-existing, and now they carry the right typespec on the wrong name | Earlgrey census | no |

## Files

| file | what |
|---|---|
| `a1_earl53.sv` | 1/2/3-level paths × {direct, concat, nested concat, replication, binary, ternary} + union / anonymous-struct / array roots + the cont-assign & procedural controls |
| `a2_earl53.sv` | mid-path select, typedef'd unpacked array, local var/net roots, output & inout directions, generate scope, generate for, instance array, interface member |
| `hpcensus53.py` | the streaming hier_path census (`--ctx` ancestor chains, `--key` the joinable TSV, `--rows`) |
| `attr53.py` | MULTISET attribution of a dump delta against the rule's signature |
| `grid53.sh` | the three-way arm grid (golden / pristine / patched) |
| `CENSUS_PREDICT53.txt` | the prediction, written before the patched database existed |
| `arm53.sh` `earl53.sh` `sweeps53.sh` `byteverify53.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `vbnd53.sh` `varm.sh` `dumptree.py` | the gate harness, carried forward from `r10earl52repro` / `r10uvm67repro` |

Three harness scripts were CORRECTED here, each by a gate that failed on them:

* `attr53.py` normalised only `file:` — `vpiRefFile:` / `vpiDefFile:` carry the
  same absolute path, and the boundary gate reported **24 LOST lines** for two
  arms that had lost nothing.
* `vbnd53.sh` carried a directory list naming `r10earl53repro`, a directory that
  exists only in the worktree, so the boundary run silently skipped this pass's
  own arms AND r10earl51/52's. It now spans 38 and 45..52 plus `$HERE`, and
  since § connPathRootTs53 is corpus-wide it no longer demands "0 differing
  arms" — it demands every differing arm be ATTRIBUTED.
* `sweeps53.sh` gained `SWEEP_BINS`, so a re-run after a patched-side-only
  rebuild does not spend an hour reproducing byte-identical pristine CSVs.

## Reproduce

```sh
git worktree add /tmp/wt_r10earl53 0424f46
cmake -S /tmp/wt_r10earl53 -B /tmp/wt_r10earl53/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build /tmp/wt_r10earl53/build -j 2            # pristine -> /tmp/r10earl53_pris_bin
git -C /tmp/wt_r10earl53 apply /tmp/r10earl53.patch
cmake --build /tmp/wt_r10earl53/build -j 2            # patched  -> /tmp/r10earl53_pat_bin
cd /tmp/wt_r10earl53/tools/probe/r10earl53repro
for a in a1 a2; do
  SLANG_UHDM=/tmp/r10earl53_pris_bin ./arm53.sh ${a}_earl53.sv /tmp/r10earl53_arm_$a
  SLANG_UHDM=/tmp/r10earl53_pat_bin  ./arm53.sh ${a}_earl53.sv /tmp/r10earl53_arm_${a}p
  ./grid53.sh $a
done
SLANG_UHDM=/tmp/r10earl53_pris_bin ./earl53.sh /tmp/r10earl53_wd
SLANG_UHDM=/tmp/r10earl53_pat_bin  ./earl53.sh /tmp/r10earl53_wdp
python3 attr53.py /tmp/r10earl53_wd/o.dump /tmp/r10earl53_wdp/o.dump
```

## GATES — all five run on the SHIPPED binaries; patched md5 `524baeafbc550296512e7c38ba7f6e9d`, pristine `5b1cf0657c877176f211f30adff39206`

| gate | result |
|---|---|
| (1) build both, `-j 2`, md5 separately | PASS — md5s above, printed by every harness run |
| (2) `tests/check_goldens.sh` | **23 PASS / 0 FAIL** on BOTH binaries; negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| (3) uhdm2rtlil, both modes | committed `gate_uhdm2rtlil.csv` vs PRISTINE testflags **0 differing rows** (baseline FIRST); vs PATCHED testflags **0**; default pristine-vs-patched **0**. `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in all four |
| (4) surelog, `--mode both` | committed `golden_surelog.csv` vs PRISTINE **0 differing rows over 1588** (baseline FIRST); vs PATCHED **0 over 1588** |
| (5) byteverify `SELFCHECK=1 SELFCHECK1=1` | uhdm2rtlil **0 movers / 1358**; surelog **4 movers / 953**, every one named and attributed below. Both controls fire on both corpora (`SELFCHECK` 1357/1358 and 952/953; `SELFCHECK1` 1 and 5 = the corruption + the 4 real movers) |
| canaries | `canaries.sh` surelog **ok=52 changed=0 absent=0**, u2r **ok=8 changed=0 absent=0**; `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` **ok=58 changed=0**, u2r `EXPECT_UNKNOWN=6` **ok=1 changed=0**; `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**; InterfaceModPort / BlackParrotComplex / YosysOldOr **byte-identical in both modes**; SVSwitch still pinned at **`4842211c4030`** in all four cells |
| boundaries | `vbnd53.sh` over `r10earl38/45/46/47/48/49/50/51/52repro` + this pass's own arms: **total=90 identical=88 attributed=2 UNEXPLAINED=0 no_output=0** — the 2 are `a1`/`a2`, this law's own arms, and `attr53.py` explains 128 and 20 added lines with 0 lost |
| DEF fence (earl38) | Earlgrey elab dump lines 1..1196437 md5 **`f58a946aba53db953a9a2a41a81a27d8` on BOTH sides** |
| UVM rows | `rowheads.sh` pristine vs patched: Scoreboard 1399779/1, SimpleUVM 1405511/1, SeqDriver 1450011/1, BuildUVMPkg 34/1, ApbSlave 0/0, SimpleConstraint 0/0, Scr1SvTests 0/0, SVSwitch 0/0 — **every number identical**. Earlgrey_0_1/default **17/1 → 82/1**, a new object |

### The four surelog byte movers, named

| mover | why | evidence |
|---|---|---|
| `default/Earlgrey_0_1` | **the target.** 5555 `ref_typespec` + 5555 `vpiExpr` added | `attr53.py`: `+49995 attributed=49995 LOST=0 UNEXPLAINED=0` |
| `default/Scoreboard` | **a COIN, not this patch.** The PRISTINE binary alone produced **three different md5s in three runs** (`2add1744…`, `89c6af70…`, `b41ba175…`) and the "pristine" and "patched" sweep hashes are two of those three | three pristine re-runs; dump delta is 46 lines of `vpiTaskFunc` list REORDER, multiset-identical |
| `default/Scr1SvTests` | **real, deterministic, content-free (R3).** 227 bytes, file size unchanged, uhdm **dump byte-identical**, CSV row byte-identical to the committed baseline | 3 pristine runs identical, 3 patched runs identical, `diff -q` on the dumps clean, `cmp -l` shows index values swapping ±1 |
| `testflags/Scr1SvTests` | same as above | 227 bytes, dump byte-identical |

---

# VERIFIER PASS (r10earl53 adversarial verification) — VERDICT: **PASS WITH ONE FIX**

Worktrees `/tmp/wt_v53` (patch as submitted), `/tmp/wt_v53pris` (0424f46),
`/tmp/wt_v53fix` (patch + the fix below). Binaries rebuilt from scratch:
pristine `5b1cf0657c877176f211f30adff39206`, patched
`524baeafbc550296512e7c38ba7f6e9d` — **both md5s reproduce the implementer's
exactly** — and verified `eb0113d50241eac04ac5bfcc0f079627`.

## THE ONE REGRESSION, AND IT WAS A MIS-BIND, NOT A DECLINE

`bindConnPathRootTs53` resolved the root by **splitting the printed path text**:

```cpp
nm = nm.substr(0, nm.find_first_of(".["));   // "ha_i.pa[1].e0" -> "ha_i"
```

**An escaped identifier may contain both delimiters.** `input req_t \pin.i ;`
`ch i (.rd_i(\pin.i .rd))` prints as `hier_path: (pin.i.rd)` whose ROOT symbol
is named `pin.i`. The split asks for `pin`.

Measured, on the arm a PREVIOUS verifier wrote for exactly this trap
(`tools/probe/r10earl37repro/v2_esc.sv`, header: *"the gate reads raw TEXT for
'.', … the classic name-reading-gate trap the ops rules name"*), which
`vbnd53.sh`'s directory list does not cover:

| cell (`v5_v53.sv`) | golden | pristine | patched | verified |
|---|---|---|---|---|
| `u_esc` `\pin.i .addr` | `struct_typespec(q53::req_t)` | **`req_t`** | **NONE — LOST** | `req_t` |
| `u_dec` `\pin.i .addr` with a real `pin` in the same conn | `req_t` | none | **`q53::dec_t` — THE WRONG STRUCT** | `req_t` |
| `u_dec` `pin.w` (the decoy itself) | `dec_t` | none | `dec_t` | `dec_t` |
| `u_brk` `\arr[0] .addr` (escaped `[`) | `req_t` | **`req_t`** | **NONE — LOST** | `req_t` |
| every `|d|` DEF-view row | none | none | none | none |

`v5_v53.sv`: pristine **CMP_FAIL 1 head**, patched **CMP_FAIL 1 head**,
verified **PASS_CMP 0 heads**. `r10earl37repro/v2_esc.sv`: the verified binary's
`o.dump` is **byte-identical to PRISTINE's** (0 lines).

The `u_dec` cell **refutes the helper's own comment** — *"A name map cannot
mis-pair; the only thing it can do is decline"*. It can and does: it bound
`\pin.i .addr` to the typespec of a different symbol called `pin`, and
`ref_typespec::Compare` reads `Actual_typespec`, so a mis-bind is a head.

**THE FIX** (`src/ModuleEmit.cpp`, 1 hunk): the root is the **LONGEST name in
`roots` that spans the path's head on a whole-component boundary**, never a
text split. Cost: **ZERO** — the verified binary's Earlgrey database is
**byte-identical** to the patched one (0 lines over 4 702 430), its three
corpus movers have the **same md5s**, and a wide sweep of **758 probe arms**
finds it differing from the patched binary on **exactly one** arm (`v2_esc`).

## HEADLINE NUMBERS — ALL REPRODUCED BIT-FOR-BIT

| claim | verifier measurement |
|---|---|
| pristine / patched md5 | identical to the report |
| Earlgrey census golden / pristine / patched | `14478 TS=6968` / `14680 TS=949` / `14680 TS=6504` — **exact** |
| shared keys / MISSING→0 / EXTRA→0 / residual 464 | `shared=13774`, `TS BROKEN=0`, `TS EXTRA-new=0`, `6968-6504=464` — **exact** |
| whole-DB attribution | `-3 +49998 | NET gained=49995 attributed=49995 LOST=0 UNEXPLAINED=0` — **exact** |
| DEF fence md5 (lines 1..1196437) | `f58a946aba53db953a9a2a41a81a27d8` both sides — **exact** |
| Earlgrey head 17/1 → 82/1 | **exact** |
| every UVM rowhead | **exact** |
| SVSwitch pin | `4842211c4030` in all four cells |
| R3 Scr1SvTests | 227 differing bytes, size unchanged, **dump byte-identical** — **exact** |

**One number did NOT reproduce, in the implementer's favour:** the surelog byte
verifier reports **3** movers here, not 4. `default/Scoreboard` did **not**
move in either of this verifier's two independent runs — corroborating the
report's own COIN classification of it.

## THE AXIS THE IMPLEMENTER'S CENSUS DID NOT AUDIT

`hpcensus53.py --key` prints `{inst, port, path, span, hangs, TS?, tsactual}` —
**`vpiExpr` is not in it**, yet `hier_path::Compare` reads `Root_value`
directly, and the rule writes it. `vhpcens53.py` adds it and `vaudit53.py`
joins on both axes. Earlgrey, golden vs pristine vs patched:

```
EXPR FIXED 5408   EXPR same-both 8366   EXPR BROKEN 0   EXPR EXTRA-new 0
TS   FIXED 5408   TS   same-both 8366   TS   BROKEN 0   TS   EXTRA-new 0
```

Clean on the unaudited axis too.

## THE WIDE BOUNDARY SWEEP — 758 arms, not 90

`vbndall53.sh` runs every `.sv` under `tools/probe/*/` with both binaries.
**patched vs pristine: 735 identical, 14 differing, 9 unbuildable-alone (all 9
identical exit codes on both binaries, including two pre-existing segfaults).**
The **uvm77–81 arms are all byte-identical**. Of the 14: 11 pure additions, all
measured **toward golden** (`r10earl29repro/v8_sites2` and `r10earl31repro/v5_hier`
go **CMP_FAIL → PASS_CMP**), `r10earl_repro/tj` is the R6 name family, and **two
are LOSSES** — `r10earl37repro/v2_esc` (the regression, fixed) and
`r10earl44repro/a1_earl44` (see V-R1).

## VERIFIER ARMS

`v1_v53.sv` unary / cast / streaming / part- and bit-select / user-call arg /
sys-call arg / literal-mixed concat / **two DIFFERENT struct roots in one
concat** / packed-array-of-struct root / hierarchical root.
`v2_v53.sv` **name collision** (a local `s` and `u_h.s`, two different symbols
of the same name) / local var + net roots in one concat / depth-2 instance tree
/ cont-assign + always + if-condition controls. **CMP_FAIL → PASS_CMP.**
`v3_v53.sv` modport interface port root / generate-for × 3 / generate-if /
instance array × 3 / struct-typed localparam root.
`v4_v53.sv` package-scoped root / enum member / **ternary with two different
struct roots** / replication-of-concat-of-binary-of-ternary / one path in two
connections.
`v5_v53.sv` the escaped-identifier roots (above). **CMP_FAIL → PASS_CMP.**

## RESIDUES THE VERIFIER ADDS

| id | what | witness |
|---|---|---|
| **V-R1** | a hier_path with an **EMPTY `VpiName`** loses the ref_typespec pristine emitted: `leaf44 u_q18 (.p_i(p44::PK_STRUCT.a))`. **Measured against golden: golden folds it to `constant 8'haa` and has no hier_path at all**, so neither side is right and no head moves — but the report's "nothing is deleted" is an Earlgrey-scoped claim, not a corpus-wide one | `r10earl44repro/a1_earl44.sv`, 7 lines lost, head unchanged |
| **V-R2** | **the law's stated closure is incomplete**: golden also attaches inside a **SYSTEM function call argument** (`$unsigned(t_i.o.w)` → `struct_typespec(top_t)` + `vpiExpr`) and **not** inside a user function call argument (`f4(t_i.o.w)` → nothing). `collect` recurses through `operation` only, so we reach neither. Pre-existing (pristine misses it too) | `v1_v53.sv` `u_sf` vs `u_fc` |
| **V-R3** | a **packed-array-of-typedef'd-struct** root (`pa_i[1].o.w`) now gains a `Root_value` where pristine had none; golden's points at a `packed_array_var` and ours at a `packed_array_net` — the pre-existing var/net divergence for that port, which is already this arm's head | `v1_v53.sv` `u_pa` |
| **V-R4** | a **struct-typed localparam** root gains a typespec on a hier_path **golden does not emit at all** (golden folds `PO.i.op`). Pre-existing extra object, now carrying a typespec | `v3_v53.sv` `u_pm` |

## GATES RE-RUN ON THE VERIFIED BINARY — all pass

goldens **23/0**, `/bin/false` **0/23**; u2r testflags vs committed baseline
**0 rows**, u2r default vs pristine **0 rows**, 679/50/2 everywhere; surelog
`--mode both` vs committed baseline **0 rows over 1588**; byteverify
`SELFCHECK=1 SELFCHECK1=1` u2r **0/1358**, surelog **3/953** with the same md5s
as the patched binary and both controls firing (1357/1358, 952/953, 1, 4);
canaries **52/0** + **8/0**; ctcan2 **58/0** + **1/0**; canaudit **29/0/0**;
InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; SVSwitch
pinned `4842211c4030`; `vbnd53.sh` **total=95 identical=88 attributed=7
UNEXPLAINED=0**; DEF fence `f58a946aba53db953a9a2a41a81a27d8`; every UVM
rowhead identical; Earlgrey **82/1**.
