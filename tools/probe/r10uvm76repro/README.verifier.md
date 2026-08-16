# r10uvm76 — ADVERSARIAL VERIFICATION of § classEnumConstBindsHoistNet76

**VERDICT: LAND.** Every number in the implementer's write-up reproduced on a
FRESH `f0d93e1` + `/tmp/r10uvm76.patch` build, including both binary md5s.
Five gates green, both corpora, both modes. The 17-line SimpleUVM head is
CLEARED on both rows and the design-wide census moved **exactly seven cells and
nothing else**. Seven ADDITIONAL arms the implementer did not build — inherited
enum constants (same package and cross package), out-of-body TASK + `fork`,
parameterized class, `$unit`-scope class, default-argument / local-declaration
initializer, and two importing modules — were measured against golden here:
six agree with golden, and the seventh (two importers) reproduces a
**pre-existing** multi-module over-mint that this pass widens to a new name
family and that does not occur anywhere in either corpus. It is reported as
finding **F-1** and residue **VR-2**, not as a blocker, on the precedent set by
§ withIterRefBindsHoistNet75's own `w3`/`w5`/`w6` arms.

Verifier tree: `/tmp/wt_v76` (patched), `/tmp/wt_v76pris` (pristine, porcelain
EMPTY). Both `rev-parse HEAD` = `f0d93e1`, grep-checked in every `cmds.txt`.

---

## 1. WHAT WAS INDEPENDENTLY REPRODUCED

| claim | implementer | verifier | verdict |
|---|---|---|---|
| patched binary md5 | `a72eeb765b73c70687aaa58f1f3cca89` | **identical** | ✔ bit-reproducible build |
| pristine binary md5 | `2ecf28a8494750468a6edcd435b8f874` | **identical** | ✔ |
| production surface | `src/ExprEmit.cpp` +55/−15 | **identical**, nothing else tracked | ✔ |
| patch md5 / lines | `bd4dda2d1a07f806622dd1fd00dc07ff` / 1788 | identical; `git apply --check` clean on fresh f0d93e1 | ✔ |
| GOLDENS | 23/0, `/bin/false` 0/23 | **23/0**, `/bin/false` **0/23** | ✔ |
| u2r testflags | 679/50/2, dump 496/183/52, 0 rows | **identical**, patched AND pristine | ✔ |
| surelog default | 469/11/25/5 | **identical** | ✔ |
| surelog testflags | 465/8/23/5 | **identical** | ✔ |
| `ct8rows` surelog | 0 rows / 0 row-sides over 1588, histograms unchanged | **identical**, patched AND pristine | ✔ |
| byte verifier u2r | 0 movers / 679, SELFCHECK 678/679, SELFCHECK1=1 | **identical** | ✔ |
| byte verifier surelog | 4 movers / 953, SELFCHECK 952/953, SELFCHECK1=5 | **identical**, `PATH_SETS_IDENTICAL` both | ✔ |
| mover shapes | REMOVED=0, ADDED=28, deltas +287/+290/+254/+254 | **identical, all four** | ✔ |
| prediction (pristine artifacts) | u2r 0/679 (0 class enum consts), surelog 574/953 (3663) | **identical**, DUMP_FAIL=0 both; all 4 movers flagged | ✔ |
| SimpleUVM census | 6273 → 6266, 29059 keys | **identical** — and see §2 for the stronger reading | ✔ |
| target head | 17 → 26, `SEQ_TYPE_LOCK`@664:54 → `ref_obj`@664:87 | **identical**; head object byte-identical to Scoreboard's | ✔ |
| SeqDriver | +28 cmp lines, 28 added / 0 removed with ids stripped | **1422659 → 1422687**, 28 added / 0 removed | ✔ |
| canaries | 9/0/0 + 52/0/0; canaudit 31/0/0; ctcan2 ok=1 unk=6, ok=58 unk=1 | **identical**, baseline first, mode-matched | ✔ |
| arms b1–b4 + v76 | 1740→1752/42→22, PASS/PASS, 1444→1444/22→22, 1840→1852/64→44, PASS/PASS | **identical, every number** | ✔ |
| uvm75 boundary | must hold | **11 of 11 arms byte-identical pristine→patched** | ✔ |

---

## 2. THE STRONGEST SINGLE MEASUREMENT: the census DELTA, not the total

The write-up reports "6273 → 6266". A total can hide a swap (seven cells fixed,
seven others broken). The verifier therefore **diffed the two census listings
key by key**:

```
diff cen_pristine.txt cen_patched.txt
  keys that LEFT the disagreement list : 7   (the seven SEQ_TYPE cells)
  keys that JOINED it                  : 0
  every other key                      : byte-identical text on both sides
```

The seven are exactly the write-up's table, spans and all
(`SEQ_TYPE_LOCK` @664:54, @677:65, @1069:21, @1175:21; `SEQ_TYPE_REQ` @763:40,
@893:38, @1079:19), each `1xNONE + 1xlogic_net` in golden and now equal.
**Design-wide, in 29059 keys, this pass moved seven cells and nothing else.**

Two further cell-level over-fire hunts, both empty:

* cells where golden binds an `enum_const` and we now bind a `logic_net`: **0**.
* cells where we bind a `logic_net` golden does not: **127 — and all 127 are
  byte-identical in the pristine census** (the pre-existing `this` /
  class-property / `event_pool` families). This pass added none.

RF-1's decode was re-measured independently: golden's `work@top` Nets vector
does repeat a **contiguous 33-net run verbatim** at indices 10–42 and 43–75
(`uvm_start_uvm_declarations` … `s_spaces`). `SEQ_TYPE_LOCK`/`SEQ_TYPE_REQ`
appear **exactly once**, at golden indices 148/150, immediately after
`item`@664:28 — and in our vector at 172/175, in the **same relative order**.
The mint was correctly NOT widened.

RF-2's substance was re-measured: for all eight qualified names
(`KILLED`, `FINISHED`, `GREEDY`, `BROAD`, `PRI_HIGH`, `PRI_LOW`,
`NAME_OVERRIDE`, `TYPE_OVERRIDE`) the reference counts are **equal on both
sides** and `logic_net (work@top.<NAME>)` count is **0 in golden and 0 in ours**.
The exact figure "24 references" could not be reconstructed with a dump-side
instrument (see F-3); the claim's substance — a real, non-empty population that
the `ScopedName` test alone keeps out of the mint — is confirmed.

---

## 3. SEVEN NEW ARMS THE IMPLEMENTER DID NOT BUILD (LHS always golden)

Files: `v76i_inherit.sv`, `v76x_crosspkg.sv`, `v76t_task.sv`, `v76g_param.sv`,
`v76u_unitclass.sv`, `v76d_defarg.sv`, `v76m_twomods.sv`. Driver: `ct76arm.sh`,
census: `ct76nets.py`, both binaries.

| arm | the cell it fills | golden | pristine | patched | verdict |
|---|---|---|---|---|---|
| `v76i_inherit` | enum constant **INHERITED** from a base class, read unqualified from the DERIVED class's OOB method | mints `B_A`@16:15, `B_B`@17:15 | none — **and this was the arm's cmp HEAD** | **= golden**, 5/5 nets, spans and order; head advances to the arms' background `class_defn` | ✔ correct, and the law's reach is wider than its own arms showed |
| `v76x_crosspkg` | same, but the base class lives in **another package** (`q76x`), the OOB body's home is `p76x` | mints `X_A`; also mints the inherited PROPERTY `bm` | neither | `X_A` **= golden**; `bm` still missing | ✔ for this law; `bm` is a PRE-EXISTING property-arm gap (VR-3) |
| `v76t_task` | OUT-OF-BODY **TASK**, one read in a plain statement and one inside `fork…join_none` | mints `T_A`@10:14, `T_B`@12:16 | neither | **= golden**, 4/4 | ✔ subroutine kind and `fork` nesting are not discriminators |
| `v76g_param` | **PARAMETERIZED** class `c76#(int W)`, OOB method | mints `P_A`@13:14 (and `W`) | none | **= golden**, 5/5 | ✔ specialization does not break `classBodyHomePkg75` |
| `v76u_unitclass` | class at **`$unit` scope** — no home package, so the site cannot fire | mints **nothing** | nothing | nothing, **byte-identical to pristine** | ✔ the null-`classBodyHomePkg75` cell is a measured negative, not an assumption |
| `v76d_defarg` | enum read from a **default ARGUMENT** and from a **body-local declaration initializer**, not from a statement | mints `V_B`@11:17 (local init) and `V_C`@14:14; **no** wire for the default-arg `V_A` | neither | **= golden** on all three, at golden's spans and in golden's relative order | ✔ two more contexts, both right |
| `v76m_twomods` | **TWO modules** both importing the package | mints `M_A` in **`aa76` only** (the FIRST importer); the ref binds `work@aa76.M_A` | no wire; ref **UNBOUND** | wires in **BOTH** `aa76` and `bb76`; the ref binds **`work@bb76.M_A`** — the LAST | ✘ **F-1**, pre-existing mechanism, widened |

`v76m_twomods` is the only disagreement, and it is exactly the shape
§ withIterRefBindsHoistNet75's verifier characterised as pre-existing
(`w3_twomods` for iterators, `w5_proptwomods` proving the property arm did it
before pass 75, `w6_siblings` for sibling importers: golden mints in ONE
hoisting module, we mint in all of them and the ref ends bound to the last).
This pass does not create the defect; it adds the enum-constant family to it.
**It cannot fire in either corpus**: the byte verifier's four movers add
`SEQ_TYPE_{LOCK,REQ}` to exactly one module each (`work@top` / `work@top_tb`).

---

## 4. NUMBERED FINDINGS

**F-1 — MULTI-IMPORTER OVER-MINT, widened to this family (non-blocking,
pre-existing mechanism, corpus-inert).** `bindHoistedClassPropRefs` runs per
module over one shared `classPropRefs` vector, so with two importers it mints a
wire in **each** and the last binder wins the reference. Golden mints in the
FIRST importer only. Measured in `v76m_twomods`: golden 6 nets / ours 8, and
`vpiActual` = `work@bb76.M_A` where golden has `work@aa76.M_A`. Before this
pass the same reference was simply *unbound*; after it, in that shape, it is
*wrongly bound*. Precedent: uvm75's `w3`/`w5`/`w6` landed with the identical
reading. Corpus impact: **zero** (verified by the 4-mover shape analysis).
Ranked **VR-2** below.

**F-2 — the CODE gate omits `curSubOob9`, which the prose and the refusal rule
both lean on; the equivalence is structural and unenforced.** The site tests
`classBodyHomePkg75`, never `curSubOob9`, while LAW C's refusal arm 170 lines
above tests `curSubOob9`. The README's refusal rule for the class PROPERTY
INITIALIZER is argued from `curSubOob9` being false there — a term the new gate
does not contain. Verified equivalent at f0d93e1: `inClassBodyEmit` /
`classBodyHomePkg75` are set at `TaskFuncEmit.cpp:2742` **inside the
per-subroutine member loop** and cleared at `:5493`, so they can only be true
while an out-of-body body is being emitted; all 13 `emitTaskFuncs` call sites
are scope-level (module / package / class), never inside expression emission,
so no re-entrancy can desynchronise them; and `b4_share`'s initializer cell
measures the consequence (wire minted at `f1`'s @19:15, not at the
initializer's @13:15). **But** `curSubOob9` is stack-saved/restored
(`:5283`/`:5454`) and `inClassBodyEmit` is not, so the two halves of LAW C are
kept in step by call-graph shape rather than by construction — the exact drift
the helper extraction was meant to prevent. No reachable witness found; recorded
so a future pass that adds a nested `emitTaskFuncs` knows it must re-check.
Cheapest hardening if ever wanted: add `&& curSubOob9` to the new arm, which is
a no-op today and makes the stated gate literal.

**F-3 — "24 qualified references" is not reconstructible from the artifacts,
and the README states it as measured.** A dump-side count of the eight named
constants gives 23 printed `ref_obj` occurrences across both views, which does
not resolve to 24 references under either the "one print per reference" or the
"two prints per reference" reading. The *claim* (a real, non-empty qualified
population, bare in golden, bare in ours, kept out of the mint solely by the
`ScopedName` test) is fully confirmed — 0 nets for all eight names on both
sides, `b3_qual` byte-identical patched vs pristine. Only the integer is
unverified. Documentation-level.

**F-4 — no finding on the head arithmetic.** "17 → 26 is an advance" was
checked, not accepted: the pristine head IS the 17-line
`logic_net (work@top.SEQ_TYPE_LOCK)`@664:54 vs `<null>`, the patched head is a
26-line `ref_obj`@664:87 vs `method_func_call` printed on both sides, and
`diff`-ing the two cmp heads with ids stripped shows it is **byte-identical to
Scoreboard's head**. The rise is a deeper object, exactly as claimed.

**F-5 — no finding on RF-6 (the LAW C arm rewrite).** Read term for term: the
old inline lambda and `classScopeEnumConst76` have the same early-outs in the
same order, and the helper's leading `EnumValue` test is the one the old arm's
`&&` supplied. Byte-confirmed at scale: 1632 databases, `REMOVED=0` everywhere,
and the census diff above shows zero collateral keys.

---

## 5. RANKED RESIDUES (verifier's ranking)

**VR-1 — `§ parensLessCallIsPathRefObj` on `item.process_id.status`, now the
head of THREE rows.** Confirmed by construction here: SimpleUVM default,
SimpleUVM testflags and Scoreboard default now stand on the *same* object
(`ref_obj (…grant_queued_locks::status)`@664:87 vs `method_func_call (status)`),
byte-identical after id-stripping. Agrees with the implementer's R1 and is the
highest-value next head.

**VR-2 — the MULTI-IMPORTER mint (F-1).** One wire per name per DESIGN in
golden (minted in the first hoisting module), one per name per MODULE in ours,
and the reference bound by the last module to run. Now carried by three name
families (properties, `with` iterators, class enum constants), so the fix is
shared and its value grows every pass. Arms already exist: `w3`/`w5`/`w6`
(uvm75) and `v76m_twomods` (here). **Ranked above the implementer's R2/R3**,
because it is a correctness disagreement rather than a missing name family.

**VR-3 — inherited class PROPERTY across packages** (`v76x_crosspkg`: golden
mints `work@top76x.bm`, we mint nothing). The pre-existing property arm is a
direct-parent test on the symbol's own class and derives its home package from
that class, so an inherited property whose base class lives in another package
never reaches the pool. Same shape as RF-5's explanation of why enum constants
were missed — one more consequence of the same direct-parent test. Not this
pass's; newly characterised here.

**VR-4 — the other 30 golden-only `work@top` net names** (implementer's R2),
re-measured here: 30 exactly, including the block-local family this pass's own
`v76d_defarg` arm reproduces in miniature (`loc`@13:15 — golden nets a body-
LOCAL variable read from an out-of-body method; we do not).

**VR-5 — the repeated 33-net declaration BLOCK** (implementer's R3, RF-1),
independently confirmed at golden indices 10–42 / 43–75.

**VR-6 — implicit-wire mint-SPAN disagreements on pre-existing shared bindings**
(implementer's R4): 17 shared names whose wire golden minted at a different
first reference (`clp` G@801:27 / O@339:3, `m_parent` G@1001:10 / O@1925:11, …).
Unchanged by this pass — this pass's own two wires land at golden's spans.

**VR-7 — the predictor's looseness on surelog** (574/953 flagged, 4 moved), and
the arms' background `class_defn` head. Both as the implementer ranked them.

---

## 6. HOW TO RE-RUN EVERY NUMBER

```sh
git worktree add --detach /tmp/wt_v76     f0d93e1 && cd /tmp/wt_v76 && git apply /tmp/r10uvm76.patch
git worktree add --detach /tmp/wt_v76pris f0d93e1
for t in /tmp/wt_v76 /tmp/wt_v76pris; do
  ~/.local/bin/cmake -B $t/build -S $t -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
     -DUHDM_DIR=$HOME/.local/lib64/cmake/UHDM -Dslang_DIR=$HOME/.local/lib64/cmake/slang
  ~/.local/bin/cmake --build $t/build -j 2; md5sum $t/build/slang-uhdm; done

# gate 2 (SLANG_UHDM has NO default -- export it)
SLANG_UHDM=/tmp/wt_v76/build/slang-uhdm ./tests/check_goldens.sh | grep -c '^PASS'   # 23
SLANG_UHDM=/bin/false                   ./tests/check_goldens.sh | grep -c '^FAIL'   # 23

# gates 3/4 (one sweep per binary per corpus, --jobs 2, own out + workdir)
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
   --jobs 2 --out /tmp/v76_u2r_<x>.csv --workdir /tmp/v76_wd_u2r_<x>
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus surelog    --mode both \
   --jobs 2 --out /tmp/v76_sl_<x>.csv  --workdir /tmp/v76_wd_sl_<x>
./tools/probe/r10uvm76repro/ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/v76_u2r_<x>.csv
./tools/probe/r10uvm76repro/ct8rows.sh results/golden_surelog.csv  /tmp/v76_sl_<x>.csv

# gate 5 (prediction FIRST, on the PRISTINE workdirs)
python3 tools/probe/r10uvm76repro/ct76predict.py /tmp/v76_wd_u2r_pris --jobs 2   # 0/679
python3 tools/probe/r10uvm76repro/ct76predict.py /tmp/v76_wd_sl_pris  --jobs 2   # 574/953
SELFCHECK=1 SELFCHECK1=1 ./tools/probe/r10uvm76repro/byteverify.sh /tmp/v76_wd_u2r_patched /tmp/v76_wd_u2r_pris
SELFCHECK=1 SELFCHECK1=1 ./tools/probe/r10uvm76repro/byteverify.sh /tmp/v76_wd_sl_patched  /tmp/v76_wd_sl_pris
./tools/probe/r10uvm76repro/mv76.sh /tmp/v76_wd_sl_patched /tmp/v76_wd_sl_pris /tmp/v76_mv

# census (span-keyed, both sides) and the DELTA that matters
python3 tools/probe/r10uvm76repro/ct76cen.py  <golden.dump> <pristine.dump> > cen_pris.txt
python3 tools/probe/r10uvm76repro/ct76cen.py  <golden.dump> <patched.dump>  > cen_patched.txt
diff cen_pris.txt cen_patched.txt          # 7 keys leave, 0 join

# arms (implementer's five + the seven added here), both binaries
for a in b1_oob b2_inbody b3_qual b4_share v76_nohoist \
         v76i_inherit v76x_crosspkg v76t_task v76g_param v76u_unitclass \
         v76d_defarg v76m_twomods; do
  SLANG_UHDM=<bin> ./tools/probe/r10uvm76repro/ct76arm.sh $a.sv /tmp/wd_$a
  python3 tools/probe/r10uvm76repro/ct76nets.py /tmp/wd_$a/g.dump /tmp/wd_$a/o.dump; done

# uvm75 boundary -- all 11 arms must be byte-identical pristine -> patched
for a in b1_oob b2_inbody b3_share b4_foreach v75_nohoist w1_declared w2_implicit \
         w3_twomods w4_task w5_proptwomods w6_siblings; do
  ./tools/probe/r10uvm75repro/ct75arm.sh $a.sv /tmp/wd75_$a; done
```

All sweep workdirs created by this verification were deleted after the
measurements; the main tree was never written to and stayed at `f0d93e1`.
