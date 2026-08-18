# r10v65 — adversarial verification of r10earl65 (§ connIpsPkgParamBoundNoTs65)

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduced bit-for-bit from an independent build. One **pristine-right →
patched-wrong** class survived their evidence and was found by a new arm axis
(interface **modport** ports); it is fixed here as
**§ connMpRootIpsBoundKeepsTs65v** and the whole battery re-run on the fixed
binary. Ship `/tmp/r10earl65.verified.patch`.

BASE 903bbea. Worktrees `/tmp/wt_v65` (patched → fixed) and `/tmp/wt_v65pris`.

| binary | md5 | note |
|---|---|---|
| pristine 903bbea | `7726630ba6667945be188d5ed47ee259` | reproduces the implementer's md5 exactly |
| implementer's patch | `66e1e8bb63d8f8f8db9f40fe954c5f0b` | reproduces theirs exactly |
| **verified (patch + fix)** | `ec7fe021b2ec605aa9ade13184ebd41d` | what the battery below measures |

All three frozen `555` at immutable paths before any sweep; every `cmds.txt`
audited by binary PATH (1462 u2r + 1573 surelog; the only slang path that
appears is the frozen one — never the main tree).

---

## 1. The regression the pass shipped, and the fix

The law suppresses the folded package parameter's declaration typespec on an
**indexed-part-select bound inside an ELABORATED port `High_conn`**. Measured on
golden, that is right for every root the implementer tried — and **wrong for one
they did not**: when the actual's hier-path ROOT is a **MODPORT-RESTRICTED
interface port** of the instantiating module, golden **KEEPS** the typespec.

Golden, arms `a9_iface.sv` / `a10_mp.sv` (`localparam int W = 16;` in a package,
`p.r.addr[0 +: W]` in a child port connection):

| root of the actual | golden's ts on the ips bound |
|---|---|
| `ifb.mp p` — modport port | **located declaration typespec** (KEEPS) |
| `ifb p` — whole-interface port | none |
| `interface p` — generic interface port | none |
| `the_if.r.addr` — interface INSTANCE named from the parent | none |
| `o_i.in.addr` — plain struct / struct-of-struct | none |

Holds on the **WIDTH** and on the **BASE**, at hier-path depth **3 and 4**, for
**both** of an interface's modport names. Six cells (a7 `u_if.i_if`, a9
`u_m3.i_m3`, a10 `u_mp.i_w` / `.i_b` / `.i_d4`, a10 `u_mp2.i_w2`) were
pristine-RIGHT and patched-WRONG.

**Why**: `NetlistElaboration::high_conn_` re-compiles the actual in the parent
instance's context, which is what loses the DEF fold's typespec — but a
modport-rooted hierarchical actual is the ONE form Surelog's `decodeHierPath`
VALUES instead (the precedent is already written down in this repo, at
`ModuleEmit.cpp`'s `modportBase8`: *"a modport-restricted interface port is the
one hierarchical form Surelog's decodeHierPath values"*), so the DEF-view stamp
survives into the elaborated connection.

**The fix** (`src/ExprEmit.cpp` + one flag in `include/UhdmExporter.h`):
`mpRoot65v` is computed once per dotted select from the AST root — slang
collapses `p.r` into a single `HierarchicalValueExpression`, so the syntactic
root is `ref.path.front().symbol`, not an expression — and the suppression
becomes `!elabConnEmit21 || mpRoot65v` at the hier-path WIDTH mint. The select's
**BASE** is folded one `emitExpr` level down by the plain arm's `ipsWidFold9`,
so a scoped `hcMpRoot65v` flag carries the carve-out there and nowhere else.
Site 1 (the AST MemberAccess chain) needs no twin: its root is a `NamedValue`
and an `InterfacePortSymbol` is not a `ValueSymbol`.

The fix is **INERT on both corpora**: the fixed binary's Earlgrey databases are
byte-identical to the implementer's patched ones (`569e2d8c49fe` /
`3c5d8bdbafa3`), and `InterfaceModPort` is byte-identical to pristine.

## 2. Reproduced, bit-for-bit

| claim | implementer | verifier |
|---|---|---|
| pristine / patched binary md5 | 7726630b… / 66e1e8bb… | **identical** |
| goldens / negative control | 23 PASS 0 FAIL / 0 PASS 23 FAIL | **23/0, 0/23** (pristine, patched AND fixed) |
| u2r testflags + default | 679 / 50 / 2 | **679 / 50 / 2** both modes |
| surelog `--mode both`, 1588 rows | 936 EQ / 20 NE | **936 / 20**, full histogram identical |
| ct8rows vs committed baselines | PASS | **PASS** (u2r tf, surelog) |
| ct8rows vs own pristine sweep | PASS | **PASS** (u2r tf + def, surelog; status AND dump) |
| byteverify u2r | MOVERS 0 / 1358 | **0 / 1358** |
| byteverify surelog | MOVERS 2 / 956 (Earlgrey ×2) | **2 / 956**, the predicted pair |
| Earlgrey ts-presence census, both modes | 95 / 9 / 1 → 95 / 0 / 1 | **identical, both modes** |
| Earlgrey scoring census, both modes | 9 TO-GOLDEN, 0 AWAY | **9 TO-GOLDEN, 0 AWAY, 0 MOVED-WRONG** |
| Earlgrey heads | 1 head/run, 17 → 36, AFTER logs byte-identical | **identical, and byte-identical to their committed `HEAD_R0_*.cmp`** |
| rowheads | 54/54/54/54/17/36/36 | **identical** |
| canaries / ctcan2 / canaudit | ok=52 / ok=8 / audited=29 UNCOVERED=0 | **identical** |
| protected DBs | SAME; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **SAME, both pins hit** |
| WIDE boundary | 2,893 .sv, only this pass's arms differ, 8 paired rc=139 | **2,903 files** (incl. these arms), PROCESSED==LISTED, **DIFFERING=24 = the 12 arm files × 2 views and nothing else**, 8 rc=139 paired A/B |
| per-DIRECTORY boundary | 1,355 dirs, arm dir + the uvm75/76 coin | **1,356 dirs**, PROCESSED==LISTED, DIFFERING=9: the 2 arm dirs × 2 views + **5 proven order coins** |

A third surelog mover, `default/Scoreboard`, appeared in one run and was
attributed the documented way: **ordered diff 92 lines, ORDER-BLIND diff 0** —
the svunit_pkg `vpiTaskFunc` list-order coin of RESUME §9, not a mover.
`r10uvm75repro` gives **three different hashes in three PRISTINE runs**;
`r10uvm88repro`'s flagged pair is a `vpiTaskFunc` list-order flip with
order-blind diff 0.

## 3. The independent instruments

* `vcen65.cpp` — owner-keyed census read straight from the `.uhdm` with a
  **strictly COMPARE-VISIBLE payload**: the four constant fields
  (`VpiConstType/VpiSize/VpiValue/VpiDecompile`) plus the typespec's
  presence, kind, `VpiName`, `VpiSigned`, range count, `Instance` and
  `Typedef_alias` — the fields `int_typespec::Compare` / `typespec::Compare`
  actually read. **No span anywhere**: the implementer's `tscen65` payload
  carries `line:col`, which is exactly the trap their own R3 records (a
  span-carrying payload mis-scores a TO-GOLDEN cell as MOVED-WRONG).
* `vscore.py` — independent keyed **MULTISET** join, five-field key, buckets
  TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-RIGHT / STILL-WRONG.
* `runarm.sh` — one arm × one view: Surelog golden + both frozen binaries,
  **rc recorded for every process**, uhdm-cmp head count, workdir-normalised
  A/B dump diff, then the score.
* `vwide.sh` / `vdir.sh` — recursive per-file and per-directory boundary over a
  **COPY** of `tools/probe`; list on **fd 3**, children `</dev/null`,
  **PROCESSED asserted against LISTED**, and **rc recorded per cell** (the
  implementer's scripts recorded a signal line only).

## 4. The arms (all 10 × 2 views; **AWAY-GOLDEN 0** on the fixed binary)

| arm | axis | TO-GOLDEN (plain/elab) |
|---|---|---|
| `a1_origin.sv` | 11 package-parameter SHAPES (implicit, `int`, `integer`, `bit[7:0]`, `logic[7:0]`, `byte`, `shortint`, `longint`, typedef'd, enum-typed, package `parameter`) + BASE + qualified spelling + arithmetic bound | 10 / 10 |
| `a2_pos.sv` | 13 POSITIONS for one parameter (ips width/base, bit-sel index, part-sel bounds, bare actual, operation operand, cast, call arg, replication count, param override, cont_assign, param_assign, range bound, case item) | 2 / 2 — **only the two ips cells move** |
| `a3_home.sv` | module body ×3 instances, gen-for, gen-if, nested gen, nested module, interface, instance ARRAY | 7 / 7 |
| `a4_hier.sv` | dotted spelling, both emitter sites, wide/negative/40-bit origins | 4 / 4 |
| `a5_ovr.sv` | module localparam (typed/untyped), port parameter DEFAULT **and OVERRIDDEN**, folded user function, literal, genvar, 72-bit | 2 / 2 |
| `a6_def.sv` | DEF-view High_conn | 2 / 2 |
| `a7_gen.sv` | the EARLGREY HEAD's shape: dotted ips in gen-for / gen-if / nested module / **interface** | 7 / 7 |
| `a8_orphan.sv` | a module with no top instantiation | 2 / 2 |
| `a9_iface.sv` | modport vs whole-interface vs generic vs instance-named vs plain struct, depth 2 and 3 | 6 / 6 |
| `a10_mp.sv` | modport at depth 3 and 4, WIDTH and BASE, two modport names, gen-for home, part-select and bit-select controls | 3 / 3 |

**88 TO-GOLDEN cells, 0 AWAY-GOLDEN, over 20 arm runs.** The measured negative
control is real and holds: in the SAME elaborated connection golden **stamps**
the part-select bound (`ts=int_typespec,sgn=1,inst=1`) while it leaves the
indexed-part-select bound bare, and the patch preserves the stamped one
byte-for-byte.

## 5. Residues found (ranked)

1. **The 95-cell mirror** (golden BARE signed `int_typespec`, ours none) is
   confirmed untouched, both modes — the implementer's R1, correctly deferred.
2. `a1_origin.sv u_imp` — an **IMPLICIT-typed** package localparam
   (`localparam IMP = 5;`) folds to `sz=64` in golden and `sz=32` in ours, in
   BOTH binaries. Scored MOVED-WRONG only because that pre-existing SIZE residue
   survives; the typespec half moved TO golden, so the cell is **strictly
   closer**. A size law, not this one.
3. `a10_mp.sv gg[*].i_g` — inside a **gen-for** under a modport port golden does
   not fold the width at all (it keeps a `ref_obj`); both binaries fold. Untouched
   by this pass, and a candidate for the modport family's next pass.
4. `a9_iface.sv u_m2.i_m2` — a modport-rooted ips at **depth 2** has **no
   High_conn operand at all** in golden. Structural, pre-existing.
5. `r10uvm88repro` joins `r10uvm75/76repro` as a directory whose dump order is a
   coin under parallel load — worth recording next to the RESUME §9 list.
