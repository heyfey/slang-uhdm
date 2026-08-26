# r10earl100 — § `structPortNetIsMemberScanOnly100`

**A struct-typed signal's NET-vs-VARIABLE class is the member scan and nothing
else.** Earlgrey_0_1 / testflags went from **26594 cmp lines / 1 head** to
**132 / 1 head**, and the new head is the *same object as the default row's* —
the queued `hmac_pkg.sv:17` typespec name. Two Earlgrey databases moved, both
predicted by name; nothing else in 2314 databases moved a byte.

Everything in this directory is **MEASUREMENT ONLY**. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

---

## 1. The head, decoded from the judge before a line of law was written

`rowheads.sh` on this pass's own pristine build (`e3d14ab934b7`):
`Earlgrey_0_1 testflags 26594 cmp lines, 1 head`.

The head object is `module_inst work@top_earlgrey.u_hmac.u_sha2.u_pad`
(`sha2.sv:290`), printed on **both** sides — which already names the failing
test, because only the **vector** `SafeCompare` overload sets both
`m_failedLhs` and `m_failedRhs` (`~/.local/include/uhdm/BaseClass.h`), and it
does so on a **size mismatch**, returning before a single element is compared.

Which vector? Read the generated Compare order, not the decompile:

| file | walks |
|---|---|
| `scope.cpp` `scope::Compare` | Property_decls, Sequence_decls, Concurrent_assertions, Named_events, Named_event_arrays, **Variables (6th)**, Virtual_interface_vars, Logic_vars, Array_vars, … |
| `instance.cpp` `instance::Compare` | `basetype_t` (= scope) first, then Programs, Program_arrays, Class_defns, Task_funcs, **Nets**, Array_nets, … |
| `module_inst.cpp` `module_inst::Compare` | `basetype_t` (= instance) first — it never touches Variables or Nets itself |

So **Variables is compared before Nets**, and a Variables size mismatch masks
everything after it.

Read straight out of both `.uhdm` files with `ct100lst` (never out of a
decompile):

```
work@top_earlgrey.u_hmac.u_sha2.u_pad
  golden    vpiVariables  8    vpiNets 16
  pristine  vpiVariables  9    vpiNets 15
```

One object, `fifo_rdata` (`sha2_pad.sv:19`, the port `input sha_fifo_t
fifo_rdata`), is in the **wrong listing**: golden lists it **once** under
`vpiNets` as a `struct_net`, we list it **once** under `vpiVariables` as a
`struct_var`.

> **CORRECTION to r10vearl99's README.** It reports "ours lists
> `…u_pad.fifo_rdata` **TWICE** in `vpiVariables` (16 entries vs golden's 16 →
> **18**)". That is a misread of the decompile: `uhdm-cmp` prints the
> `|vpiVariables:` header before **every** element of the vector, so the header
> that follows the surplus entry reads like a second copy. The counts are
> **8 vs 9** and **16 vs 15**, and `fifo_rdata` appears exactly once on each
> side. Anyone reproducing this pass from the 16/18 framing will not find it.

---

## 2. The decoded model — Surelog, read verbatim

Surelog decides net-vs-variable for a struct-typed signal in
`ElaborationStep::elab_signal_`'s **typespec dispatch**
(`Surelog/src/DesignCompile/ElaborationStep.cpp:1906-1955`), and the only input
it reads is the `struct_typespec`'s **member typespecs**. This repo already
carries the two scans, decoded by earlier passes, in `src/EmitHelpers.h`:

* **LOOSE** (`structTsIsNetLike`, EmitHelpers.h:208) — every member's actual
  typespec is a `logic_typespec` **or** a `struct_typespec` ⇒ NET. This is the
  scan `elab_signal_` runs for a signal written with **no packed dimensions**.
* **STRICT** (`structTsIsNetStrict`, EmitHelpers.h:246) — `SURELOG::Struct::
  isNet()` (`Design/Struct.cpp:44`), every member a **plain logic_typespec**;
  a nested struct member fails it. Reached through `bindStructInPackage`
  (`ElaborationStep.cpp:1233-1247`), which `signal->setType(paNetType_Wire)`s
  an **explicitly `pkg::`-qualified** struct — and that is a **`VpiNetType`**
  effect, not a listing effect (§4 R1).

There is **no drivenness term, no direction term and no `var`-keyword term** in
either scan. Measured against Surelog directly (`a2_drive100.sv`,
`g2_uses100.sv`), a net-like package struct stays a `struct_net` as:

| shape | golden |
|---|---|
| `input` port, read only, module has no child instance | `struct_net` |
| `output` port driven by a **blocking** `always_comb` | `struct_net` |
| `output` port driven by a continuous assign | `struct_net` |
| `output` port driven by an `always_ff` `<=` | `struct_net` |
| port handed straight to a child instance | `struct_net` |
| port nothing drives or reads at all | `struct_net` |
| `inout` port | `struct_net` |
| port written **`input var al_t p`** | `struct_net` |
| body decl, plain / `var` / `wire` / with an initializer | `struct_net` |
| bare (wildcard-imported) **or** `pkg::`-qualified | `struct_net` |

and a **non**-net-like one (an `enum` member, a `bit` member) is a `struct_var`
in every one of those same cells. `g1_forms100.sv` scores the member axis
directly: `netlike_t` / `nested_t` (struct member) / `viatd_t` (a member typed
by `typedef logic [7:0]`) ⇒ NET; `enummem_t` / `bitmem_t` ⇒ VAR.

---

## 3. What was wrong, and the law

`src/ModuleEmit.cpp` carried a **drivenness** route for struct ports:

```cpp
if (isStruct && it.port && !it.bodyDecl &&
    (procWritesStructPort || undrivenStructPorts.count(it.sym)) &&
    !it.sym->getDeclaredType()->getInitializer() &&
    isPkgStructType(*it.sym) && !isExplicitPkgQualified(*it.sym)) { … struct_var … }
```

fed by a module-wide walk (a `touched` set over every procedural LHS, every
cont-assign LHS and every child-instance port connection) built ~90 lines
earlier.

**It could only ever fire where golden emits a NET.** The member-scan route
above it (`memberDemotesToVar = isStruct && !structTsIsNetLike(ts)`) takes every
non-net-like struct and `continue`s, so this route is reached **only** when
`structTsIsNetLike(ts)` is true — i.e. exactly the case golden nets. It was
wrong wherever it reached.

**Its own two precedents reproduce without it**, measured on their goldens:

* `rsp_gen_minimal` — `tlul_pkg::tl_d2h_t` has member `tl_d_op_e d_opcode`, an
  **enum**. The member scan already makes `tl_i`/`tl_o` `struct_var`s; the
  drivenness term was never what produced them. (Golden confirms: `dut`'s
  `vpiVariables` = `tl_i`, `tl_o`, `rsp_intg`, `rsp`, `unused_payload`; `vpiNets`
  is a **null vector**.)
* `simple_package` — `my_pkg::bus_transaction_t` is all logic, and golden lists
  `bus_in`, `bus_out` **and** `internal_bus` as `struct_net`s in both the top
  and the submodule. The route suppressed exactly the nets this test needs.
* The comment's third precedent, `rp32 r5p_bru`'s read-only `input dec_t dec`,
  is the same story: `riscv_isa_i_pkg::dec_t` opens with `ill_t ill` and carries
  `opc_t`, `fn3_t`, `fn7_t`, … enums. Golden: `struct_var dec` — from the member
  scan, with no drivenness term anywhere.

**THE LAW: delete the route and the walk that fed it.** −143 / +34 lines in
`src/ModuleEmit.cpp`, one file, nothing else. The § comment at the deletion site
carries the decode; a second § note replaces the walk.

---

## 4. The census (`CENSUS.r10earl100.txt` carries it in full)

`ct100cen.cpp` keys **listing membership + object kind + vector size** —
precisely what the judge reads here — for every scope of every database, view
(`D` = `AllModules`, `E` = `TopModules`) in the key. `cen100.py` joins the two
sides as **multisets**.

**Calibration:** 0 one-sided cells and 0 count mismatches on all **1358**
uhdm2rtlil databases (23620 scopes, 31664 cells), every one of which uhdm-cmp
calls `CMP_EQUAL`. Zero false positives.

| universe | pristine | patched |
|---|---|---|
| uhdm2rtlil 1358 DBs / 23620 scopes | BOTH-SAME 31664, ONLY-GOLDEN 0, ONLY-OURS 0, nV-bad 0, nN-bad 0 | **identical** |
| surelog 956 DBs / 41146 scopes | BOTH-SAME 205841, ONLY-GOLDEN 372, ONLY-OURS 4, nV-bad 8, nN-bad 10 | BOTH-SAME 205845, ONLY-GOLDEN 368, **ONLY-OURS 0**, nV-bad 4, nN-bad 6 |

Each side's **cell total is invariant** — golden 205845+368 = 206213 = 205841+372,
ours 205845+0 = 205845 = 205841+4 — which is the arithmetic proof that the four
cells changed **listing** and that nothing was added or removed on either side.

**TO-GOLDEN 4 · AWAY-GOLDEN 0 · ADDED 0 · REMOVED 0 · MOVED-WRONG 0.**

The four cells are the whole population, and they are the whole corpus reach of
the deleted route — quoted verbatim, both modes identical:

```
G-ONLY x1 E|module_inst|work@top_earlgrey.u_hmac.u_sha2.u_pad|fifo_rdata               N:struct_net
O-ONLY x1 E|module_inst|work@top_earlgrey.u_hmac.u_sha2.u_pad|fifo_rdata               V:struct_var
G-ONLY x1 E|module_inst|work@top_earlgrey.u_usbdev.i_usbdev_iomux|sys_reg2hw_config_i  N:struct_net
O-ONLY x1 E|module_inst|work@top_earlgrey.u_usbdev.i_usbdev_iomux|sys_reg2hw_config_i  V:struct_var
```

Both are the same shape: an `input` port of a **package** `struct packed`,
referenced **bare** through a wildcard import, in a module that wires no struct
port. `hmac_pkg::sha_fifo_t` is `{sha_word_t data; logic [WordByte-1:0] mask;}`
(a typedef-of-logic member and a logic member — LOOSE-net);
`usbdev_reg_pkg::usbdev_reg2hw_phy_config_reg_t` is nine anonymous
`struct packed { logic q; }` members (all struct members — LOOSE-net, and it is
the witness that the **loose** scan governs, not the strict one). After the law
Earlgrey does not appear in the census report in **either** mode.

**Explicit listing COUNTS, both columns, for the head's own module:**
`u_pad` golden `nV=8 nN=16`; pristine `nV=9 nN=15`; patched `nV=8 nN=16`.

**What does NOT move** (pre-existing, byte-identical before and after, a
different family): MiniAmiq 71 / SeqDriver 82 / SimpleUVM 31 ONLY-GOLDEN cells
in both modes, led by
`D|interface_inst|work@svaunit_vpi_interface|UVM_UNBOUNDED_CONNECTIONS
N:logic_net` — a DEF-view interface listing.

---

## 5. The grid (`arm100.sh`, both views, both frozen binaries)

`ARM100.r10earl100.txt` carries the table. Axes: **declaration form**
(plain `logic` / package struct / anonymous packed struct / `wire` of struct
type / `var` of struct type / with a structured, positional or literal
initializer / unpacked array of struct / packed array of struct / local
typedef) × **member composition** (all logic / nested struct / typedef-of-logic
/ enum / packed-array / `bit`) × **use** (read only / continuous assign /
blocking `always_comb` / non-blocking `always_ff` / both / port-connected to a
child / member select assigned / nothing at all) × **home** (top module /
submodule / a submodule instantiated twice / gen scope / interface /
parameterized submodule ×2 widths / package function / class / module function
/ always-block local) × **spelling** (bare wildcard import vs explicit `pkg::`)
× **view** (plain and `-elabuhdm`).

| arm | view | pristine | patched |
|---|---|---|---|
| `a1_bare100` | plain | 2496 / 1 head | **0 / 0 — uhdm-cmp EQUAL** |
| `a1_bare100` | elab | 2548 / 1 head | **0 / 0 — uhdm-cmp EQUAL** |
| `a2_drive100` | plain | 4474 / 1 | 29 / 1 |
| `a2_drive100` | elab | 4663 / 1 | 29 / 1 |
| `g1_forms100` | plain | 2403 / 1 | 29 / 1 |
| `g1_forms100` | elab | 2463 / 1 | 29 / 1 |
| `g2_uses100` | plain | 509 / 1 | 509 / 1 |
| `g2_uses100` | elab | 509 / 1 | 509 / 1 |
| `g3_neg100` | plain | 1154 / 1 | 1154 / 1 — **databases BYTE-IDENTICAL** |
| `g3_neg100` | elab | 1144 / 1 | 1144 / 1 — **databases BYTE-IDENTICAL** |

`a1_bare100` **converts outright in both views**. The 29-line residue on
`a2`/`g1` is R1 below (one `wire`-declared struct, `VpiNetType`), not a listing
cell. `g2`'s 509 lines are R2 below — an **interface** residue that is
identical on both binaries and masks the law's own cells in that arm; the
listing census is the arbiter there, and it reads every moved cell TO-GOLDEN
(`u_ro.p`, `u_ca.p/r`, `u_cb.p/r`, `u_none.p/r`, `u_pass.p`, `u_par.p` on both
widths, `u_pass.u_leaf.p`, and `g2_top`'s own `t_p`), AWAY 0.

**Negative control `g3_neg100`** — package-function struct local, class struct
property, module-function struct local, always-block struct local, local
(non-package) typedef, and the whole pattern-init family (structured /
positional / `'0` literal, on both a net-like and a var-kind struct) — produces
**byte-identical databases on both binaries in both views**. The law touches
none of them.

---

## 6. Gates (`GATES.r10earl100.txt` carries the raw output)

* Binaries frozen `chmod 555` at immutable paths **of the same length**:
  pristine `400a941` `e3d14ab934b7`, patched `6b5ee27cfaa9`.
* `check_goldens.sh` with `SLANG_UHDM` exported **to each binary**: **23 PASS /
  0 FAIL**; negative control `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL**.
* Status histograms, patched vs this pass's own pristine sweep — **identical**:
  surelog 937 CMP_EQUAL / 19 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL
  / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM;
  uhdm2rtlil **679 / 50 / 2** in **both** modes.
* `ct8rows` **PASS** on all five comparisons (u2r-tf vs the committed
  `results/gate_uhdm2rtlil.csv` in this worktree, u2r-tf / u2r-def / sl vs this
  pass's own pristine sweep, sl vs the committed `results/golden_surelog.csv`).
  `results/*.csv` untouched. **No row converts**: the Earlgrey rows were and
  remain `CMP_NOTEQUAL`.
* `byteverify SELFCHECK=1`, patched vs this pass's own pristine sweep:
  **uhdm2rtlil MOVERS 0 / 1358** (SELFCHECK 1357/1358 flagged),
  **surelog MOVERS 2 / 956** — `./default/Earlgrey_0_1` and
  `./testflags/Earlgrey_0_1`, **exactly the predicted set and nothing else**
  (SELFCHECK 955/956 flagged, `PATH_SETS_IDENTICAL` on both).
  No `Scoreboard`/default coin flip occurred in this run.
* Every `cmds.txt` audited **by binary path**: **0 of 3035** name the main-tree
  binary; both sweeps ran `/tmp/…_lawA.bin` / `/tmp/…_pris.bin`.
* `canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r);
  `ctcan2.sh` **PASS** on both; `canaudit.sh canaries.sh ctcan2.sh`
  **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
* Protected databases by name, patched vs pristine: `InterfaceModPort`
  `BlackParrotComplex` `YosysOldOr` **SAME** in both modes; `SVSwitch`
  **`4842211c4030`**; `YosysVerx` **`6ccda350c24a`**.
* `rowheads.sh` on the seven named rows, pristine → patched:
  SeqDriver 17/17, SimpleUVM 67/67, Scoreboard-default 67, MiniAmiq 106/106,
  BuildUVMPkg 67/67, Rggen-default 0 — **every one unchanged**;
  **Earlgrey_0_1 testflags 26594 → 132**, default 132 → 132.
  (`SKIP-NOFILE` on Scoreboard/testflags and Rggen/testflags as expected.)
* Wide boundary (`BOUNDARY_WIDE.txt` attributes every cell): **4493 files**,
  both views, both frozen binaries, workdir-normalised dump byte-compare, file
  list on **fd 3**, children `</dev/null`, **PROCESSED = LISTED = 4493**.
  `identical 8614 · DIFFERING 16 · no_output 356`; rc histogram
  `0:16514  3:684  4:746  139:28`, the 28 segfaults **symmetric 14 per side**
  (R4). The 16 differing cells are 8 files × 2 views and **every one is
  attributed**: four of this pass's own arms (the **positive control** — the
  gate can see the law; `g3_neg100` is in the list and correctly absent from
  the diff), `r10earl77repro/g1_portkind77.sv` (**TO-GOLDEN ×2, AWAY 0** —
  `i_impstruct`/`o_impstruct` become the `struct_net`s golden lists; index-blind
  distance 44 → 40), `r10sing3_pa3.sv` (**converts** — 1394 cmp lines / 1 head
  → uhdm-cmp **EQUAL**), and `r10buvm22repro/g22.sv` +
  `r10uvm154repro/l154_noenum.sv`, whose whole diff is the one layout-derived
  garbage constant (`22527705` vs `22556377`) that uvm154 §7 / earl99 R7
  characterised — **equidistant from golden on both binaries** (identical cmp
  lines 1719/1719 and 8/8, identical head counts, 0 listing-census cells).
  **Zero unattributed movers.**

**FENCED=** the four slang-fenced test names are NOT spelled anywhere in this
directory except inside `canaudit.sh`, which carries them as its fence list (the
same convention every earlier pass follows, so the integrator's
`awk … | grep -v canaudit | grep -c .` fence check reads **0** on this patch).
The boundary list was filtered by those four names before a single child ran,
and the filter matched **0 files** — none was dispatched.

---

## 7. Ranked residues this pass MEASURED and deliberately did not take

* **R0-testflags (the new head) — QUEUED, NOT THIS FAMILY.** The testflags row's
  head is now the **same object as the default row's**: `hmac_pkg.sv:17`, a
  `logic_typespec` whose `VpiName` golden writes **`sha_word_t`** (with a
  `Typedef_alias` `ref_typespec` to `hmac_pkg::sha_word_t`) and we write
  **`hmac_pkg::sha_word_t`**. 132 cmp lines, 1 head, both modes, byte-identical
  logs. Surelog's naming is context-dependent (campaign memory:
  *naming-context-dependent*) and r10earl96 owns the family — do not "fix"
  `pkg::pkg::` uniformly.
* **R1 — `wire <pkg-struct> name;` LOSES `VpiNetType`.** `g1_forms100`'s
  `d_wire` and `a2_drive100`'s `y4`: golden `struct_net … |vpiNetType:1`
  (`vpiWire`), ours `0`. `nets::Compare` **does** read `VpiNetType`
  (`nets.cpp`), so it is judge-visible, and it is the only thing left in those
  two arms (29 cmp lines, 1 head). Pre-existing — the pristine binary scores it
  identically — and **0 corpus cells**. The same field has a decoded sibling
  already in the tree: an **explicitly `pkg::`-qualified** struct signal takes
  `vpiWire` from `bindStructInPackage`'s `setType(paNetType_Wire)` (measured:
  `p_net_qual` `nt=1` vs `p_net_bare` `nt=0` on the same typedef), which the
  interface emitter already models at `ModuleEmit.cpp:27988`. Its own law, its
  own census.
* **R2 — AN INTERFACE'S STRUCT MEMBER SKIPS THE MEMBER SCAN.** `g2_uses100`'s
  `if2.i_var` (`gp2::v3_t`, an enum member): golden `struct_var` under
  `vpiVariables`, ours `struct_net` under `vpiNets`. It is the head of both
  `g2` arms and is **identical on both binaries** (pre-existing, untouched).
  The fix is the mirror of the gen-scope route (`ModuleEmit.cpp:14172`, which
  already runs `structTsIsNetLike`) at the interface site
  (`ModuleEmit.cpp:27984`), which today always mints a `struct_net`.
  **0 corpus cells** (the census reports no interface struct cell in either
  corpus), and the interface cluster is a known 41-test hazard — deliberately
  left to a pass that can census it on its own arms.
* **R3 — A PACKAGE-TYPEDEF STRUCT WITH A STRUCTURED PATTERN INIT.**
  `a2_drive100`'s `al_t d_init = '{a:4'h1, b:4'h2};` — golden: `struct_net`
  spanning the NAME with a net-decl cont_assign; ours: `struct_var` spanning the
  whole declaration, carrying the pattern as its `vpiExpr` (the `structuredPkgPat`
  route, `ModuleEmit.cpp`). Unchanged by this pass and byte-identical on
  `g3_neg100`, which carries the whole init family as a negative control.
  **0 corpus cells.** Its own law — the pattern-init routes have their own
  precedents and this pass deliberately did not disturb them.
* **R4 — A `pkg::vec_t [N:0]` PORT IS A NET, NOT A `packed_array_var`.** Surfaced
  by the wide boundary's attribution of `r10earl77repro/g1_portkind77.sv`:
  `i_pkgvecdim` / `o_pkgvecdim` (a package vector typedef with a written packed
  dimension) are `packed_array_var`s under `vpiVariables` in golden and plain
  `logic_net`s under `vpiNets` in ours — the **STRICT** scan's territory
  (`structTsIsNetStrict`: written packed dims make the typespec a
  `packed_array_typespec`, which is not net-like at all). Identical on both
  binaries; the same arm also carries a `p77::s1_t` typespec-NAME residue
  (earl96's family). **0 corpus cells** — the census reports no such cell in
  either corpus. Its own law, its own census.
* **R5 — THE PRE-EXISTING PROBE / BOUNDARY SEGFAULTS.** The wide boundary's rc
  histogram is symmetric side for side. Recorded by earl82 R6 / earl83 R6 /
  earl84 R6 / earl85 R5 / earl89 R6 / earl90 R8 / earl91 R5 / earl93 R7 /
  earl94 R6 / earl95 R4 / earl96 R5 / earl97 R5 / earl99 R8; `byteverify`
  proves none of them is a mover.

---

## 8. Files

| file | what |
|---|---|
| `ct100lst.cpp` | direct `.uhdm` reader: a scope's Variables / Nets / Array_nets / Ports by name, kind, span and typespec. Earlgrey's `uhdm-dump` is gigabytes; this reads the database. |
| `ct100cen.cpp` | the listing census — `SIG`/`CNT` lines keyed on view, home, name; payload = listing + kind, and the vector sizes |
| `cen100.py` | the three-way multiset scorer over a `verify_golden` workdir |
| `arm100.sh` | the arm scorer: every arm × {plain, elab} × {pristine, patched}, judged by `uhdm-cmp` against a Surelog golden built in place |
| `wide100.sh` | the wide boundary (fd-3 list, `</dev/null` children, `PROCESSED` asserted) |
| `a1_bare100.sv` | bare vs `pkg::`-qualified × the member scan — **converts outright** |
| `a2_drive100.sv` | drivenness × direction × `var`/`wire` keyword |
| `g1_forms100.sv` | declaration forms × member composition |
| `g2_uses100.sv` | uses × homes (module / submodule / gen scope / interface / parameterized ×2) |
| `g3_neg100.sv` | the negative control — byte-identical on both binaries |
| `CENSUS.r10earl100.txt` | the census write-up; `CEN_*.txt` the raw reports |
| `ARM100.r10earl100.txt` | the arm table |
| `GATES.r10earl100.txt` | the raw gate battery |
| `BOUNDARY_WIDE.txt` | the wide boundary, every differing cell attributed; `.diff` `.tally` `.rc_histogram` `.rc_by_side` the raw output |
| `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp` | the head logs, both modes |
| `PREDICT_R0.txt` | the mover prediction (made from pristine databases) and R0 |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, carried so this directory is self-contained |
