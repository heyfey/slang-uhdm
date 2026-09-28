# r11u199: second adversarial verification of passes 192 and 193 (verifier; measurement plus three refinements in fix.patch)

Base `58905f76` (branch matrix-1.87). Pass 192 (the expression/parameter ground: eight r11u192 laws and v11u192's
refinement) landed at `b6344400`; pass 193 (the module/type ground: seven r11u193 laws and v11u193's three refinements)
landed at `b8719ea9`. On top of them sit the verification r11u194 (`4a65840e`, § tpCaPortNetIsVar194v and
§ incDecSelCallArgRead194v) and the map r11u197 (`58905f76`, tools only). Worktree `/tmp/wt_r11u199` (system-deps
configuration, `-j 2`, `-j 1` for the fix rebuilds); scratch `/tmp/r11u199_*`.

This directory is the deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited,
and `tools/uhdm-strictcmp/` is not edited (no comparator defect was found). The three refinements are
[fix.patch](fix.patch), a `git diff 58905f76 -- src` (`src/ExprEmit.cpp`, `src/ModuleEmit.cpp`). It applies clean on a
fresh `58905f76` and on pass 195's `7eb6f4b5`, which landed on the main tree during this pass. It is NOT applied here.

The brief speaks of "the canonicalisation patch you were given". No such patch was handed to this pass.

The brief lists § pkgTfBodyCmViewClone192 among pass 192's laws. It is not one of them. It is the 2026-09-07 block-3
"UVM pass 192" (`287bbc94c`, [ParamEmit.cpp](../../../src/ParamEmit.cpp) `bindPkgTfBodyClassMethodClones192`). It has no
switch, and `git show b6344400 -- src` does not name it. `R11V192_OFF` is not a switch either: v11u192's refinement
reads only `R11V192_WHOLELHS_OFF`, and it lives inside two pass-192 branches, so `R11U192_OFF` drops it. The
composition wrappers set `R11V192_OFF` as the brief asks. It is a no-op.

The cases name their laws in their first line (`// § law`), so `tests/LAWS.md` reads STALE in every sweep here. A clean
`58905f76` checkout reads STALE too (`python3 scripts/law_index.py --check` in a fresh worktree at the base:
`law index STALE`, rc 1). That is the only red of every sweep below.

The slang-fenced tests are named nowhere in this directory. [drivers/env.sh](drivers/env.sh) resolves the repository
from its own path, reads `$FENCED` from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and refuses to run
without four names. Every driver here that reads corpus sources or databases sources it and skips the four names by word
boundary. No gdb was used. Only the gate sweeps dispatched fenced rows.

## Verdict

**Three breaks, each refined behind its own switch in [fix.patch](fix.patch).** Every other law of the two landings
holds on 85 fresh cases in both views (default and `--elabuhdm`). The landings compose additively: no pair of laws
cancels another's error at status or byte level. Every CHANGE line of both integrations is a strict subset. The
downstream lanes are byte-identical to golden's on every converted row.

- **B1: § genForWholeLhsNestedKeep192v declines where the right-hand side's root is a system call.**
  - **Shape:** a for-generate continuous assignment to a whole outside net whose right-hand side is rooted in a system
    call: `assign z = $unsigned({1'b0, x[W:0]});`, `$signed({1'b0, x[W:0]})`, `$unsigned(x[W:0] | 32'd0)`,
    `$unsigned({x[31:W], 1'b0})` (cases W/w3, s3, s4, s5).
  - **The error:** golden names the folded bound's reference by the owning instance (`work@top.u`). The refinement
    writes the select's name (`work@top.u.g[0].x`).
  - **Cost:** STRICT_EQUAL with `R11V192_WHOLELHS_OFF`, STRICT_NOTEQUAL `fullname` at HEAD, in both views. That is 8
    case-modes of `strict:LOST` in [lawtable.txt](evidence/grid/lawtable.txt). The stage-1 variants (w1, w2, s6,
    a11) also lose golden-agreeing dump lines.
  - **Decode:** `UhdmWriter::writeCont_assign`
    ([UhdmWriter.cpp](../../../third_party/Surelog/src/DesignCompile/UhdmWriter.cpp) line 2121, the first leg). It
    re-clones an assignment to a whole name (`lhs` a `ref_obj` that `bindVariable` finds) only when
    `rhs->UhdmType() == uhdmoperation`. The clone re-parents the substituted constant under the select. A
    system-call root is not an operation, so the constant keeps its `param_assign` parent from `getValue`
    (CompileExpression.cpp 2903-2905). v11u192's rule reads "the fold is not the whole right-hand side". The rule
    Surelog applies is "the right-hand side's root is an operation". That also closes v11u192's residue 1: the
    mechanism is decoded.
  - **Controls:** a system call nested under an operation or a conditional (s1, s10) is still cloned in golden, so
    the refinement stands there. A user function call root (`id({1'b0, x[W:0]})`, w4, s8) keeps the select name in
    golden, so the refinement stands there too. fix2 applied the new rule to every invocation, which moved w4 and s8
    away. fix3 limits it to system names.
  - **Fix: § genForWholeLhsCallRootOwner199v** (`R11V199_GFCALLROOT_OFF`; ExprEmit.cpp `caRhsRootIsCall199v`). Both
    branches of the refinement (the owner branch and the replication-count branch) no longer decline when the
    right-hand side, parentheses stripped, is an invocation of a system name.
- **B2: § psBoundPaOwnerName192 × § caUnsizedRhsClonePerInst193 (cross-ground).**
  - **Shape:** a definition's continuous assignment that the unsized-clone law clones per instance, holding a part
    select bounded by a wildcard-imported package parameter: `assign y[3:0] = c ? x[W:0] : '0;` (X/x07) and
    `assign y[W:0] = c ? x[3:0] : '1;` (X/x08; x03 holds both).
  - **The error:** § psBoundPaOwnerName192 names the definition's constant reference by its owner, `work@m`, which
    is right in the definition listing. The clone copies that name, and the drain's `defNamed` test only drops names
    with a `.` after the definition path. The clone therefore keeps `work@m`, where golden's per-instance clone reads
    `work@top.u_a.x` (right side) or `work@top.u_a.y` (target).
  - **Cost:** with pass 192 off (193 on) those records match golden. With both on, they are wrong: 2 records per
    case-mode, chain-keyed AWAY in [recaway2.txt](evidence/grid/recaway2.txt), both views.
  - **Fix: § ucCloneUnnamesOwnerTs199v** (`R11V199_UCOWNER_OFF`; ModuleEmit.cpp `unsizedRhsCloneDrain193`). A
    constant or operation typespec reference named exactly the definition's full name counts as definition-derived
    too.
- **B3: § caUnsizedRhsClonePerInst193 on an element-select target.**
  - **Shape:** `assign y[0][K:0] = c ? x[3:0] : '0;` (X/x09, U/u06 `y[1][W-1:0]`, x03). The target is a `var_select`,
    which the drain's `unname` does not descend.
  - **The error:** the clone keeps `work@m.y`, `work@m.y.y` and `work@m.y.y.K`. Golden reads `work@top.u_a.y`,
    `work@top.u_a.y.y` and `work@top.u_a.y.y.K`.
  - **Cost:** in `--elabuhdm` the law's own switch has these records right, because the walk only diverges later, at
    #310. x09_el, u06_el and x03_el are AWAY by 6, 6 and 4 chain-keyed records. In the default view the clone objects
    did not exist before, so it is an incomplete unmasking, not AWAY.
  - **Fix: § ucCloneUnnamesVarSel199v** (`R11V199_UCVARSEL_OFF`; same drain). A `var_select` and its index
    expressions are unnamed like bit and part selects.

`R11V199_OFF` drops all three. `R11U193_OFF` drops the two clone refinements (they run inside that law's drain), and
`R11U192_OFF` drops the call-root refinement.

**Fix measurements** (section 7):
- **The fix's moves:** 28 case-modes move over the 1142 case-modes of this directory and of the evidence cases of
  r11u192repro, v11u192repro, r11u193repro, v11u193repro, r11u194verify, r11u115repro, v11u115repro and r10rgg9repro,
  both views. All 28 are in this directory.
  - Every one reads 0 golden-agreeing dump lines lost.
  - 21 go STRICT_NOTEQUAL -> STRICT_EQUAL.
  - The stage-1 ones move closer to golden.
- **Switches:** `R11V199_OFF=1` gives law.bin's bytes on all 1142. Each switch alone restores law.bin's bytes on
  exactly its own cases.
- **Fix sweep:** reads 0/0/0 in every stage.
  - `probe.csv`, `uhdm2rtlil.csv` and `downstream.csv` are byte-identical to HEAD's. `surelog.csv` differs only in the
    LowMem log-path texts.
  - byteverify: 8 of 2560 corpus movers, all the UVM coin; 0 of 4087 probe movers; 0 of 871 downstream slang-lane
    movers.
  - The frozen prediction named 3 databases as an upper bound (Earlgrey_0_1 d/t, Rggen d). None of them moved.
- **Rebuild:** fix.patch on a fresh `58905f76` rebuilds to fix.bin's md5 bit for bit.

**No other law moves a field away from golden on fresh legal SV** (85 cases; 83 judgeable in both views, n07 has no
golden and R/r01 is a residue case; section 3):
- **STRICT_EQUAL**, both landings off -> HEAD -> fix:
  - default view: 6 -> 37 -> 47;
  - `--elabuhdm`: 6 -> 37 -> 46.
- **Judge-equal (uhdm-cmp):** no case leaves it. With the landings on, T/t01 and t02 enter it in `--elabuhdm`.
- **Crashes:** none. Every run in every state is rc 0 or rc 4 ("unsupported constructs" with a database, C/c08 and
  X/x06 in every state).
- **Downstream:** T/t01 and t02 go DIVERGENT -> IDENTICAL with § caTernFillArmKept193. No case leaves IDENTICAL in any
  state.

**Composition: additive** (section 5). CANCEL is 0 at status level in all three stages. At byte level there is 1
CANCEL in 6647 databases, and it is the UVM coin (SeqDriver t, 0 or 4 order-blind lines).
- **The two integrations, reproduced by switches:** both landings off equals `706ab521`'s committed baselines
  exactly, and 193 off equals `b6344400`'s (= `4a65840e`'s), in all three stages: 0 regressions, 0 conversions,
  0 changes.
- **Each landing converts exactly its claimed set:**
  - pass 192: 18 probe cases and 4 u2r row-modes (ibex_icache d/t, iface_zero_width_field d/t);
  - pass 193: 144 probe cases and 2 u2r row-modes (rsp_gen_minimal d/t).
- **The wide base:** the same conversions reproduce with passes 187, 188 and the r11u190 and r11u194 refinements
  switched off.

## 1. Binaries and states (frozen `chmod 555` in `/tmp/r11u199_bin` before any measurement; [binaries.txt](evidence/binaries.txt))

| binary | md5 | what |
|---|---|---|
| `law.bin` | `4519cd58f7833bd1ac01afb706d3d45f` | worktree build of `58905f76` = the main tree's `build/slang-uhdm` at the start of this pass (`4519cd58f783`) |
| `fix1.bin` | `00ee74a158c6…` | + the two clone refinements (superseded) |
| `fix2.bin` | `904dcf81b946…` | + the call-root refinement on every invocation (superseded: moved w4/s8 away; its sweep was stopped in the surelog stage, [sweep_swF_fix2_aborted.log](evidence/sweeps/sweep_swF_fix2_aborted.log), probe stage 0/0/0) |
| `fix.bin` = `fix3.bin` | `1a85570ca96cec4f1463679d3e883b5a` | `58905f76` + [fix.patch](fix.patch) (`2bc1c676be91…`); a fresh `58905f76` worktree + fix.patch rebuilds this md5 |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

State wrappers ([drivers/mkstate.sh](drivers/mkstate.sh)), all running law.bin under switches:

| wrapper | switches | the state |
|---|---|---|
| `alloff.sh` | `R11U192_OFF R11V192_OFF R11U193_OFF R11V193_OFF` | both landings off (= `706ab521` + r11u194's refinements) |
| `off192.sh` / `off193.sh` | `R11U192_OFF R11V192_OFF` / `R11U193_OFF R11V193_OFF` | one landing off (`off193` = `4a65840e`) |
| `wide.sh` | alloff + `R11U187_OFF R11U188_OFF R11V188_OFF R11V190_OFF R11V194_OFF` | the brief's composition list |
| `wideon.sh` | `R11U187_OFF R11U188_OFF R11V188_OFF R11V190_OFF R11V194_OFF` | the same with the two landings on |
| `pre192.sh` / `post192.sh` | alloff + `R11V194_OFF` / `R11U193_OFF R11V193_OFF R11V194_OFF` | `706ab521` / `b6344400` exactly (not swept: see 5.1) |

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/queue.sh](drivers/queue.sh); `/tmp/r11u199_sw?`, same-length names)

Every sweep's 3273 corpus `slang:` lines name its own binary or wrapper ([cmds_audit.txt](evidence/sweeps/cmds_audit.txt)).
Every golden came from the cache (3273 of 3323 runs served; the rest are the deferred and failing rows). Counts:
[state_counts.txt](evidence/sweeps/state_counts.txt).

| sweep | state | probe EQUAL | surelog d+t CMP_EQUAL | u2r d+t | gate vs results/ |
|---|---|---|---|---|---|
| swH | law.bin, all four stages | 3299 | 460+456 | 793+793 | **0/0/0** in every stage; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0; `downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv` |
| swA | alloff | 3137 | 460+456 | 790+790 | = `706ab521`'s committed csvs (0/0/0 in all three stages) |
| sw2 | off192 | 3281 | 460+456 | 791+791 | reg 18 probe + 4 u2r (exactly pass 192's conversions) |
| sw3 | off193 | 3155 | 460+456 | 792+792 | = `b6344400`'s committed csvs (0/0/0) |
| swW / swO | wide / wideon | 3026 / 3188 | 456+452 | 789 / 792 | - |
| swF | fix.bin, all four stages | 3299 | 460+456 | 793+793 | **0/0/0**; `probe.csv`, `uhdm2rtlil.csv`, `downstream.csv` byte-identical to swH's |

Canaries ([canaries_H.txt](evidence/sweeps/canaries_H.txt), [canaries_F.txt](evidence/sweeps/canaries_F.txt)):
`r11u107repro/canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh`
(surelog) and `EXPECT_UNKNOWN=6 ctcan2.sh` (uhdm2rtlil) PASS, on swH and swF. uhdm-cmp reads 0 lines on every row the
landings touch (every judge-equal status is kept in every sweep).

## 3. The fresh cases, per law ([cases/](cases), [evidence/grid/](evidence/grid))

85 cases in 13 groups, none in the grids of r11u192repro, v11u192repro, r11u193repro or v11u193repro. The first line
names the laws each case attacks.
- [drivers/case.sh](drivers/case.sh) builds the golden with the pinned Surelog (check_probe's arguments; `EL=1` adds
  `-elabuhdm` / `--elabuhdm`).
- [drivers/grid.py](drivers/grid.py) runs each case in both views against these states: ON; each named law's own
  switch (a refinement also under its parent's); each landing off; every pair of named laws (group X); ALLOFF; WIDE.
- Every cell is also judged by [fieldscore.py](drivers/fieldscore.py), [recaway2.py](drivers/recaway2.py) (chain-keyed
  strict records) and [dumpaway2.py](drivers/dumpaway2.py) (order-blind reachable uhdm-dump).
- Tables:
  - [lawsum_head.txt](evidence/grid/lawsum_head.txt) and [lawtable.txt](evidence/grid/lawtable.txt): HEAD against
    each law's switch;
  - [lawsum_fix.txt](evidence/grid/lawsum_fix.txt): fix.bin as ON;
  - [case_table.txt](evidence/grid/case_table.txt): every case's strict verdict, ALLOFF / HEAD / FIX, both views.

| group | cases | shapes (the brief's list) |
|---|---|---|
| A | a01-a13 | bounds through wildcard imports of two packages (a01); an explicit import beside a qualified bound (a02); a for-generate right side, whole outside targets (a03); if/case-generate scopes and conditions (a04); target selects, generate targets (a05); positional and named port-connection selects, two instances (a06); replication counts in a for-generate (a07); `always_ff`, `always @(*)`, `initial` (a08); a task and a function (a09); net declaration assignments in two instances with a `logic` initializer (a10); whole outside targets under `?:`, `-`, a call, `$unsigned`, a replication, `&` (a11); a bind instance (a12); macro arguments (a13) |
| V | v01-v04 | a select through an interface port (v01), a modport (v02), a generate-scope net (v03), two instances of one child (v04) |
| Q | q01-q03 | nested qualifiers (a package parameter defined from another's, `p::A[p::S-2]`, `((p::T))`) (q01); class-scoped `p::C::W`, `K::V` (q02); a qualifier inside a macro body, a macro argument, a macro name (q03) |
| P | p01-p03 | a pattern read in a generate loop's bound (p01), a struct typedef aliased twice (p02), a pattern read in a package function (p03) |
| C | c01-c08 | casts of casts (c01), of concatenations (c02), positional (c03), an interface instance and a bind (c04, pass 193's residue), a package-parameter operand (c05), an array net's initializer (c06), signed/unsigned (c07), `W'(r)` / `(W+1)'(r)` (c08) |
| S | s01-s04 | `$bits` / `$clog2` (s01), nested system calls (s02), a call of a cast (s03), positional (s04) |
| T | t01-t05 | `'0 '1 'x 'z` on both branches (t01), nested three deep over four instances (t02), in a generate loop (t03), a struct net and a member target (t04), an interface continuous assignment (t05, pass 193's residue) |
| U | u01-u07 | behind a parameter reference (u01), every base `'h 'o 'b 'd 'z` (u02), a concatenation target with part selects (u03), a whole unpacked target (u04; a queue is no legal continuous-assignment target), a generate-loop target (u05), three instances of different widths (u06), behind a variable and a cast (u07) |
| N | n01-n07 | two and three deep with selects (n01), instantiated twice (n02), a package typedef and enum literals (n03), every select kind (n04), a generate inside (n05), a nested program (n06), a nested interface (n07: Surelog's parser rejects it, no golden) |
| O | o01-o05 | two importers by name around one writer (o01), a program writer (o02), an interface writer (o03), a writer module in an included header (o04), a package importing the package (o05, pass 193's residue) |
| W | w1-w8, s1-s10 | the B1 distinguisher: whole outside targets under `$unsigned`, `$signed`, `$countones`, a user function, `-`, `?:`, parentheses, `$bits`, system calls nested under an operation or a conditional |
| X | x01-x09 | the brief's cross-ground pairs (section 5.3) and B2/B3 (x07-x09) |
| R | r01 | residue N1 (no law of these passes) |

Per law, both views, HEAD against the law's own switch ([lawsum_head.txt](evidence/grid/lawsum_head.txt)):

| law | cases | reading (cells) | verdict |
|---|---|---|---|
| § psBoundPaOwnerName192 | 35 | TOWARD 22, STAGE1-CLOSER 6, **MIXED 6 (x03, x07, x08: AWAY 2 records each, B2)**, UNFIRED 36 | **BREAK B2** (cross-ground; fixed) |
| § genForReplCountOwner192 | 12 | TOWARD 4, UNFIRED 20 | holds |
| § procPsBoundOwner192 | 4 | TOWARD 2, UNFIRED 6 | holds |
| § tfPsBoundOwner192 | 1 | TOWARD 1, STAGE1-CLOSER 1 | holds |
| § ndaPsBoundOwner192 | 2 | TOWARD 4 (x03's two away records are a chain-key collision with the clone's B2 records: the dump shows the nda constant moves to golden's `work@top.u_a`) | holds; a `logic` variable initializer is not covered (a10: residue N3) |
| § caPsSelFullVerbatim192 | 7 | TOWARD 3, BYTES-ONLY 3, UNFIRED 8 | holds |
| § pkgQualBoundSpanQualifier192 | 4 | TOWARD 6, STAGE1-CLOSER 2 | holds; the class-scoped `K::V` span is not this law's (q02: residue N2) |
| § pkgPatReadTsBindsTopTypedef192 | 4 | TOWARD 1, STAGE1-CLOSER 2, STAGE1-AWAY 5 (p01, p02 both views, p03) | holds: the raw-dump distance grows only in the unreachable `\_weaklyReferenced` tail (dumpaway2 reads 0 lines changed; recaway2 away 0): r11u192's identity class |
| § genForWholeLhsNestedKeep192v | 19 | TOWARD 12, **AWAY 8 (w3, s3, s4, s5, `strict:LOST`)**, STAGE1-AWAY 6 (w1, w2, a11, s6), STAGE1-CLOSER 2, STAGE1-SAME 4 | **BREAK B1** (fixed) |
| § castOperandLeafElab193 | 12 | TOWARD 3, BYTES-ONLY 3, STAGE1-CLOSER 8, STAGE1-SAME 4 | holds (c01/c03 lose one dump line `logic_net r` and gain it back elsewhere; chain-keyed away 0) |
| § connCastTsNamedByPort193 | 11 | TOWARD 8, STAGE1-CLOSER 10 | holds |
| § connSysCallArgDefNet193 | 6 | TOWARD 10 | holds |
| § caTernFillArmKept193 | 6 | TOWARD 2, STAGE1-CLOSER 2 (t01/t02 `--elabuhdm` stage 1 -> STRICT_EQUAL) | holds; downstream **t01, t02 DIVERGENT -> IDENTICAL**; the dump-lost lines are `vpiParent` prints of the shared constant (identity) |
| § caUnsizedRhsClonePerInst193 | 12 | TOWARD 4, UNMASK 6, MIXED 5, STAGE1-CLOSER 2; **AWAY in `--elabuhdm` on x09, u06, x03 (B3)** | **BREAK B3** (fixed); B2's partner |
| § nestedDefChainName193 | 7 | TOWARD 8, MIXED 2 (n05: field level FTOWARD, lost 22), STAGE1-CLOSER 2 | holds |
| § tfArgOutsideCopyOrder193 | 5 | TOWARD 4, UNMASK 2, MIXED 1 (o02_el: FTOWARD, lost 28), STAGE1-CLOSER 1, STAGE1-SAME 2 | holds |
| § nestChainKeepsPkgQual193v | 1 | UNFIRED 2 (n03 converts on the parent law alone) | holds |
| § nestChainSelects193v | 4 | TOWARD 2, MIXED 2 (n05, FTOWARD) | holds |
| § ucCloneUnnamesRanges193v | 4 | TOWARD 2, UNFIRED 6 | holds (x08's owner-named bound is B2's) |
| § tpCaPortNetIsVar194v | 1 | STAGE1-SAME 2 (x06) | holds |

With fix.bin as ON ([lawsum_fix.txt](evidence/grid/lawsum_fix.txt)), § psBoundPaOwnerName192 reads TOWARD 36 and
STAGE1-CLOSER 14. § caUnsizedRhsClonePerInst193 reads TOWARD 15 and STAGE1-CLOSER 2. § genForWholeLhsNestedKeep192v
reads TOWARD 12 and STAGE1-CLOSER / SAME 6, with no AWAY. The remaining judge flags are the non-breaks named above.

### 3.1 The flagged cells that are not breaks

- **U/u07 FAWAY (fieldscore):** the object counts differ between the states (the clone adds 11 objects), so an
  index-keyed field comparison is meaningless there. The chain-keyed judge reads away 0 and the dump judge lost 0. The
  fix converts u07 (§ ucCloneUnnamesOwnerTs199v: the `8'(...)` typespec named `work@m`).
- **The P cases, STAGE1-AWAY:** the identity class of r11u192 section 4 (a shared typedef printed once). The reachable
  dump is identical.
- **T/t01, t02, lost dump lines:** the vpiParent back-references of the fill constant, which golden shares between
  instances. The strict verdict goes to STRICT_EQUAL, and downstream goes to IDENTICAL.

## 4. The breaks, record by record ([fixjudge.txt](evidence/fix/fixjudge.txt), [fix_W_cases.txt](evidence/fix/fix_W_cases.txt))

B1 on W/w3_unsigned_cat (`assign z = $unsigned({1'b0, x[W:0]});` in `for (genvar i...) begin : g`):

    #222 fullname  golden ref_typespec work@top.u      HEAD work@top.u.g[0].x     R11V192_WHOLELHS_OFF / fix: work@top.u (STRICT_EQUAL, 226 objects)

B2 on X/x07_clone_rhs_psbound (`assign y[3:0] = c ? x[W:0] : '0;`, two instances):

    both landings off     #56 def listing work@m.x (golden work@m), #213 u_a clone work@m.x (golden work@top.u_a.x), + c, x, y names
    192 off, 193 on       #56 work@m.x (wrong), the clones' #213/#278 = golden
    HEAD                  #56 = golden, #213/#278 work@m (AWAY)
    fix                   STRICT_EQUAL (285 objects)

B3 on X/x09_clone_varsel_lhs `--elabuhdm` (`assign y[0][K:0] = c ? x[3:0] : '0;`):

    R11U193_UNSIZEDCLONE_OFF   records up to #309 = golden (u_a's var_select work@top.u_a.y ...), walk diverges at #310 (depth)
    HEAD                       #238 var_select work@m.y, #240 part_select work@m.y.y, #241 ref_obj work@m.y.y.K (x2 instances): AWAY
    fix                        STRICT_EQUAL (326 objects)

The fix's own switch matrix ([fixbound.txt](evidence/fix/fixbound.txt)):
- `R11V199_GFCALLROOT_OFF` alone restores law.bin's bytes on the W and a11 movers.
- `R11V199_UCOWNER_OFF` alone restores them on x07, x08 and u07.
- `R11V199_UCVARSEL_OFF` alone restores them on x09 and u06.
- x03 needs both clone switches.
- `R11V199_OFF` gives law.bin's bytes on all 1142 case-modes.

Downstream: every fix mover reads the same verdict under law.bin and fix.bin
([cases_FIX.txt](evidence/downstream/cases_FIX.txt)). The breaks are strict-axis only, because the plugin does not
read `ref_typespec` full names.

## 5. Composition ([evidence/composition/](evidence/composition))

### 5.1 The two landings ([compose_H_A_2_3.txt](evidence/composition/compose_H_A_2_3.txt), [bytecancel_H_A_2_3.txt](evidence/composition/bytecancel_H_A_2_3.txt), [states_vs_history.txt](evidence/composition/states_vs_history.txt), [claimed_vs_own.txt](evidence/composition/claimed_vs_own.txt))

H = HEAD, A = both off, 2 = pass 192 off, 3 = pass 193 off (the 1588 surelog rows are 1596 minus the 8 fenced, skipped
unread).

| stage | conversions A -> H | owner | changes A -> H | CANCEL |
|---|---|---|---|---|
| probe | 162 | OWN192 18 (= the 18 names `706ab521 -> b6344400` converted), OWN193 144 (= the 144 names `4a65840e -> b8719ea9` converted) | OWN192 4, OWN193 7, JOINT 1 (`r10earl31repro/v5_hier`: `endcol(6)` -> 192 `fullname(2)` -> 193 `fullname(1)`) | 0 |
| surelog | 0 | - | OWN192 2 (Earlgrey_0_1 d/t `col(98) -> col(91)`) | 0 |
| uhdm2rtlil | 6 | OWN192 4 (ibex_icache d/t, iface_zero_width_field d/t), OWN193 2 (rsp_gen_minimal d/t) | OWN193 2 (ibex_pmp d/t `file(5) -> type(1)`) | 0 |

- **Byte level** (6647 databases): SAME 6450, OWN192 27 (probe 22; ibex_icache d/t, iface_zero_width_field d/t,
  BuildUVMPkg d), OWN193 163 (probe 156; rsp_gen_minimal, ibex_pmp and genvar_loop_decl_2 d/t, Rggen d), and BOTH 6.
  The BOTH databases are v5_hier, Earlgrey_0_1 d/t, MiniAmiq d/t and SeqDriver d. There is 1 CANCEL, SeqDriver t.
- **The UVM rows are the coin:** every UVM mover between H, 2 and 3 reads 0 or 4 order-blind lines
  ([coin_movers_H_vs_offs.txt](evidence/uvm/coin_movers_H_vs_offs.txt)): the `types_t` bound, `UINT:0` against a
  value. Neither landing fires on any UVM row (the census, section 10).
- **The switch states reproduce the committed history exactly:** swA = `706ab521` and sw3 = `b6344400` (=
  `4a65840e`), 0/0/0 in all three stages. The `R11V194` refinements, on in both, move nothing there, so
  `pre192.sh` / `post192.sh` needed no sweep of their own.

### 5.2 The wide base ([wide_vs_head.txt](evidence/composition/wide_vs_head.txt))

With passes 187 and 188 and the r11u190 and r11u194 refinements off (swO against swW), the landings convert exactly the
same rows: probe 162, u2r 6, surelog 0. They also change the same rows: probe 12, surelog 2, u2r 2. No conversion
depends on those passes, and none hides a pair of laws cancelling each other.

### 5.3 Cross-ground pairs (group X, each pair off together; [grid_default.txt](evidence/grid/grid_default.txt))

| case | pair | reading |
|---|---|---|
| X/x01 | § psBoundPaOwnerName192 × § castOperandLeafElab193 (`.d(7'(r[W:0]))`, `.d(7'({r[9:W], 1'b0}))`) | TOWARD alone and in every pair; STRICT_EQUAL on |
| X/x02 | § caPsSelFullVerbatim192 × § connSysCallArgDefNet193 × § connCastTsNamedByPort193 (a select, a cast and `$unsigned(x[W+4:4])` in one connection list) | TOWARD in every pair; STRICT_EQUAL on |
| X/x03 | § ndaPsBoundOwner192 × § caUnsizedRhsClonePerInst193 (an unsized-right-side nda and a cloned select target, bounds from a package parameter) | **B2 + B3**; fix: STRICT_EQUAL both views |
| X/x04 | § pkgPatReadTsBindsTopTypedef192 × § nestedDefChainName193 (a pattern read in a nested definition) | STAGE1-CLOSER alone and together |
| X/x05 | § genForReplCountOwner192 × § caTernFillArmKept193 (`(P) ? {R{2'b01}} : '1` in a generate loop) | every law UNFIRED: the fold inside a generate loop is stage 1 in every state (residue N4) |
| X/x06 | § tpCaPortNetIsVar194v × § castOperandLeafElab193 (an enum-typed `output wire T` port written by `T'(si)`, `.si(3'(r))`) | 193 CLOSER; 194v SAME; stage 1 in every state (residue N5) |
| X/x07-x09 | B2, B3 | fixed |

## 6. The CHANGE lines ([evidence/changes/](evidence/changes), [drivers/unmask.py](drivers/unmask.py))

- **Pass 192's integration (swA -> sw3 = `706ab521 -> b6344400`,
  [unmask_192_swA_to_sw3.txt](evidence/changes/unmask_192_swA_to_sw3.txt)):**
  - probe: CONVERSION 18, SUBSET 5 (e4_ctrl 17 -> 2, v4_ops 14 -> 4, v5_hier 6 -> 2, vo 8 -> 6, a8_orphan 5 -> 2);
  - surelog: SUBSET 2 (Earlgrey_0_1 d/t `col(98) -> col(91)`: all 91 records among the 98, walk diverged in both);
  - u2r: CONVERSION 4.
- **Pass 193's integration (sw3 -> swH = `4a65840e -> b8719ea9`,
  [unmask_193_sw3_to_swH.txt](evidence/changes/unmask_193_sw3_to_swH.txt)):**
  - probe: CONVERSION 144, SUBSET 8 (v5_hier 2 -> 1, l_concat 2 -> 1, gv29_b_positions 3 -> 2, k40/k42/v13/v22
    9 -> 7, b07_rv2arr 8 -> 1);
  - u2r: CONVERSION 2, SUBSET 2 (ibex_pmp d/t 5 -> 1: the `type` record was already in the off walk).
- **No NEW, no WORSE:** every CHANGE is a strict subset of the off records.
- **The brief's list is exact:** pass 192's Earlgrey change reads `col(98) -> col(91)` at the integration base; the
  `col(102) -> col(95)` pair belongs to pass 192's own base `a1c89c1a`.

## 7. Downstream ([evidence/downstream/](evidence/downstream))

- **Converted rows:** ibex_icache, iface_zero_width_field, rsp_gen_minimal, ibex_pmp, genvar_loop_decl_2 and
  tern_fill_literal.
  - `_nohier.il`, `.il` and `_synth.v` are byte-identical between golden's lane and the slang lane in swH
    ([dsnet_H.txt](evidence/downstream/dsnet_H.txt)).
  - The same holds with both landings off ([dsnet_A.txt](evidence/downstream/dsnet_A.txt), the harness filtered to
    the six rows under `alloff.sh`). The slang databases move (five of the six md5s differ) but the netlists do not:
    `ibex_icache,IDENTICAL,OK,OK,3610,3610`, `rsp_gen_minimal,IDENTICAL,OK,OK,154,154`.
- **The full downstream gate:** swH and swF `downstream.csv` are byte-identical to the committed baseline (803 / 66 /
  2 / 0). The fix moves 0 of 871 slang-lane databases.
- **v11u193's four cases** ([v11u193_tf_cases.txt](evidence/downstream/v11u193_tf_cases.txt)): tf02_widths,
  tf03_concat_z, tf05_mixed and tf09_x_ports read IDENTICAL at HEAD and EQUIVALENT with both landings off, as
  reported.
- **This pass's 85 cases** ([dscase.py](drivers/dscase.py); states ALLOFF / OWN / ON / FIX):
  - 71 IDENTICAL in all four states, and 2 DIVERGENT -> IDENTICAL with § caTernFillArmKept193 (T/t01, t02).
  - 6 EQUIVALENT and 5 DIVERGENT in every state; these are pre-existing stage-1 faces, residues N4-N7.
  - n07 has no Surelog reference.
  - No case leaves IDENTICAL in any state.
- **UVM file facets, order-blind** ([uvmdist_H_A_F.txt](evidence/uvm/uvmdist_H_A_F.txt)): identical in H, A and F.
  - MiniAmiq dist 7143 / all_file_away 2646.
  - SeqDriver 5801 / 2381.
  - SimpleUVM 2579 / 1362.
  - Scoreboard d 1950 / 1082.
  - BuildUVMPkg 1036 / 187.
  - `method_func_call` file facets: 12 (0 on BuildUVMPkg).
- **First records at HEAD** ([first_records_H.txt](evidence/uvm/first_records_H.txt)):
  - MiniAmiq #899: `uvm_severity` enum file;
  - SeqDriver #1677: `uvm_bitstream_t` file;
  - SimpleUVM #458 and Scoreboard #466: `UVM_MACRO_NUMFLAGS` full names;
  - BuildUVMPkg #2834: `severity` through `uvm_report::verbosity`.
  - These are the same as r11u194's report. No law of either landing fires on these rows.

## 8. Determinism ([evidence/determinism/](evidence/determinism), [drivers/det.sh](drivers/det.sh), [drivers/ob.sh](drivers/ob.sh))

| row-mode | law.bin concurrent runs | reference sweep |
|---|---|---|
| Earlgrey_0_1 default | **1 hash in 6/6** (`46612df2e13d`) | = swH's and swF's |
| Earlgrey_0_1 testflags | **1 hash in 6/6** (`9358af9983e2`) | = swH's and swF's |
| MiniAmiq d / t | 3 runs: 3 / 1 hashes (+ the sweep's: 4 / 2) | every pair 4 order-blind lines |
| SeqDriver d / t | 3 / 3 (+ sweep: 4 / 4) | 4 lines (one t pair 0) |
| SimpleUVM d / t | 3 / 1 (+ sweep: 4 / 1) | 4 lines (one d pair 0) |
| BuildUVMPkg d / t | 1 / 1 (`e4f8e660c7d5`; the swH default sweep drew `e025a6f404c3`) | 0 lines |

- **The UVM one-constant coin still stands at the base.** Every 4-line pair is the right bound of
  `array_typespec types_t` (uvm_misc.svh 642:23-26), `vpiDecompile` / `UINT` `0` against a value (943, 1229, 638,
  857 ...; [uvm_coin_context_seqdriver_t.txt](evidence/determinism/uvm_coin_context_seqdriver_t.txt)). Every variant
  reads uhdm-cmp 0 lines, the same strict cell and the same object count.
- **r11u196 has not landed:** the main tree's HEAD moved to pass 195 (`7eb6f4b5`) during this pass. No commit on
  the branch names `queueRetTwinDynShape191` in `src/`.
- **BuildUVMPkg's order-only draw confirmed** ([buildvmpkg_draw.txt](evidence/determinism/buildvmpkg_draw.txt)):
  - The two hashes' uhdm-dumps are identical, object ids included. The files have the same size, and 7573 bytes
    differ from offset 3.26 MB.
  - The draw lives in the Cap'n Proto storage order only, and no reader that resolves by id can see it.
  - It is drawn per invocation: the sweep's testflags run gave `e4f8`, its default run `e025`, and the fix sweep the
    reverse.
- **The fix sweep's 8 corpus movers against HEAD are this coin**
  ([movers_orderblind_F_vs_H.txt](evidence/sweeps/movers_orderblind_F_vs_H.txt)): MiniAmiq d/t, SimpleUVM d and
  SeqDriver t at 4 lines; BuildUVMPkg d/t, Scoreboard d and SeqDriver d at 0 lines.

**A process finding on the brief's inputs.** `/tmp/strict_sweep` is not a `58905f76` sweep. Its files are dated
2026-09-24, its Earlgrey rows read `CMP_EQUAL ... differ:line(381)`, and it differs from this pass's HEAD sweep by 55450
and 336426 order-blind dump lines (default / testflags). Nothing here rests on it: every measurement uses this pass's
own frozen binaries and sweeps.

## 9. Residues

### Re-measured at the base (`58905f76`, r11u194 on top; [cases_at_head.txt](evidence/residues/cases_at_head.txt))

| source | residue | at 58905f76 |
|---|---|---|
| pass 192, R1 | anon_struct_packed_dim d/t fullname(43) | **stands** (`differ:fullname(43)` both modes) |
| pass 192, R2 | a path nested in another path's index (r11u178 h09) | **stands** (`col`, both views) |
| pass 192, R3 | StructParamPatternInitCast d/t fullname(3) | **stands** |
| v11u192, 1 | the whole-outside-target mechanism undecoded | **decoded here** (B1: writeCont_assign's first leg, root operation) and refined |
| v11u192, 2 | the qualifier span declines in a parameter initializer (qk07) | **stands** (`endcol`, both views) |
| v11u192, 3 | macro-born qualifiers across two buffers (qk01) | **stands** (`endcol`) |
| pass 193, 1 | ibex_pmp d/t type(1) | **stands** |
| pass 193, 2 | the r11u115 generate-scope substituted package-parameter typespec name (22 probe cases at pass 193's base) | **15 closed by pass 192** (24 not-EQUAL at `706ab521` -> 9 at `b6344400` and HEAD); the 9 left are system-call or concatenation arguments of a bare `W` (p05, p12, a01, a06, a09, a13, a18, a20, v06) |
| pass 193, 3 | an interface instance's cast actual (CL/s12) | **stands** (`fullname`); fresh C/c04 likewise |
| v11u193, 1 | two outside writers (pm01) | **stands** (`line`) |
| v11u193, 2 | package-internal references to a moved typedef (pm07) | **stands** (`fullname`) |
| v11u193, 3 | cast leaves in interface and bind connections (s12, bc09) | **stands** (`fullname`); fresh C/c04 and A/a12 (a bind's select: golden `work@top.u.u_chk.a.x`, ours `work@top.u_chk.a.x`) likewise |
| v11u193, 4 | interface continuous assignments (tf07, uc22) | **stands** (stage 1 in `--elabuhdm`); fresh T/t05 stage 1 both views |
| r11u193, 6 | r18, s13, p07 stage 1 | **stand** (17 / 46-50 / 180 cmp lines); fresh O/o05 = p07's shape (180 lines) |

### New, found here (none is a break but B1-B3, which are fixed)

These are ranked by downstream visibility, then by reach.
- **N5.** An enum-typed type-parameter output port written by a cast (`output wire T so; assign so = T'(si);`, X/x06):
  - stage 1 with 215 cmp lines and rc 4 in every state;
  - DIVERGENT downstream in every state.
- **N6.** Casts in an array net's initializer (`wire [6:0] w [2] = '{7'(r), 7'(r >> 3)}; wire signed [6:0] v =
  signed'(7'(r));`, C/c06):
  - stage 1 at the `$signed` sys_func_call's typespec;
  - DIVERGENT downstream in every state.
- **N7.** `$bits(x[W:0])` as a whole for-generate right side (W/w8): stage 1, DIVERGENT downstream in every state.
- **N4.** A fill-literal conditional in a generate loop (T/t03, X/x05) and a fill onto a member target
  (`y[1].a = (P) ? '0 : ...`, T/t04):
  - golden folds or keeps the located `'0`; ours keeps the operation, or an unlocated `UINT:0`;
  - § caTernFillArmKept193 does not reach generate-scope or hier_path targets;
  - t03 and x05 are EQUIVALENT downstream.
- **N1.** A positional actual that is an operation (`sub u2 (r[6:0] + 7'd1, r[6:0], o2);`, R/r01, C/c03):
  - golden lists a `ref_module` for the instance in the definition listing, ours none (stage 1, 357 cmp lines);
  - it is ModuleEmit's, and pre-existing in every state.
- **N3.** § ndaPsBoundOwner192 does not cover a `logic` VARIABLE declaration's initializer (`logic [31:0] v4 = x[W:0];`,
  A/a10): golden `work@top.u1`, ours `work@top.u1.v4.x`.
- **N2.** A class-scoped reference in a part-select bound (`x[K::V:p::S]`, Q/q02) spans `K::` only: ours ends at
  13:20, golden at 13:21. It is pre-existing in every state; the qualifier-span law does not touch it.
- **N8.** The remaining stage-1 faces of the fresh grid are listed with their comparator paths in
  [stage1_faces_head.txt](evidence/residues/stage1_faces_head.txt). Each is identical with the landings off.
  - a user function call around a folded bound in a for-generate (w4, s8): the call's constant argument;
  - `$unsigned(x[W:0])` / `$signed(x[W:0])` in a for-generate definition listing (w1, w2, a11): ours writes a
    `ref_obj x[W:0]`;
  - the positional cast sum (c03);
  - `pk::P` as a cast operand (c05);
  - a size cast `(W+1)'(r)` (c08);
  - a nested program (n06);
  - an interface-port select (v01) and a generate-scope net select (v03) as connection actuals;
  - the package pattern reads (p01-p03, x04).
- **N9.** A nested interface declaration (`module sub; interface nif; ... endinterface ... endmodule`, N/n07) is
  rejected by the pinned Surelog's parser (SNT:PA0207). No golden exists.
- **N10.** `connCastTsNamedByPort193` has no case in `tests/LAWS.md` ("cases in the gate: none; cases in the evidence:
  none"). No first line in r11u193repro or v11u193repro names it; every cast case names `castOperandLeafElab193`. This
  directory's C, S and X cases now name it.

## 10. The fence and the process ([evidence/process/](evidence/process))

**No law, case or number here rests on a fenced reading.**
- Every case is this directory's.
- Every corpus reading goes through a fail-closed driver or a gate sweep: bvmirror.sh reads `fenced_skipped=8` on
  both mirrors; census193.sh filters the fenced rows (`--filter` from `$FENCED`); obpair.sh, det.sh, ob.sh and
  uvmdist.sh refuse fenced names; compose.py, bytecancel.py and unmask.py skip them unread.

**The laws nearest the fenced tests' parameter shapes, re-derived from this directory's cases and Surelog's source only:**
- **§ psBoundPaOwnerName192:** `CompileHelper` substitutes a parameter by `clone_tree(param_ass->Rhs())` with
  `VpiParent(param_ass)` (CompileExpression.cpp 2903-2905, 2971-2973). `writeCont_assign`'s first leg re-clones an
  assignment to a whole name only under an operation root (UhdmWriter.cpp 2121-2135), and its fourth leg re-clones
  any assignment holding an unsized constant (2283-2291). Cases A (13), W (18), X/x07-x09. This is where B1 and B2
  were found.
- **§ pkgQualBoundSpanQualifier192:** Q/q01-q03 and A/a02 (a qualified bound beside a wildcard one): TOWARD or
  converted. The class-scoped span is a separate face (N2).
- **§ caUnsizedRhsClonePerInst193:** the `DetectUnsizedConstant` leg (UhdmWriter.cpp 2078, 2283). Cases U (7) and
  X/x03, x05, x07-x09. This is where B3 was found.
- **§ caTernFillArmKept193:** the fill-literal taken branch kept as its own located constant. Cases T (5) and X/x05.
  t01 and t02 are STRICT_EQUAL in both views and IDENTICAL downstream.

**Drivers of the four evidence directories** (static reading plus a runtime source of each env.sh,
[fencecheck.txt](evidence/process/fencecheck.txt)):
- **The four env.sh:** each resolves the repository from its own path and reads the `FENCED=` line of
  `tools/probe/r11u107repro/canaudit.sh`, never RESUME.md. Sourced from the checkout: rc 0 with 4 names. Sourced
  from a scratch copy beside a two-name canaudit.sh: rc 1 with 2 names (fail closed). A word scan finds 0 files
  naming a fenced test in any of the four directories or this one; the positive control finds a planted name.
  - r11u192repro's env.sh also requires `SLANG_UHDM`.
  - r11u193repro's and v11u193repro's also require `R193_BIN` / `V193_BIN`.
- **r11u192repro:**
  - Source env.sh and refuse a fenced path: boundary.sh, grid.sh, head.sh, probemovers.sh, rowrec.sh, rows.sh (rows.sh
    refuses a regex that matches a fenced name), census.sh (`--filter` built from `$FENCED`).
  - Read canaudit.sh themselves (four-name check): chgcheck.py, offcheck.sh, switchmatrix.sh.
  - Require `$FENCED` with four names and skip by word boundary: bvmirror.sh.
  - Require `$FENCED` (`:?`) without a count check and skip by word: obrows.sh.
  - **Do not check the fence:** censum.py, recdist.py, recmv.py, obdist.py and tsnames.py (readers of a given trace or
    dump); gridcmp.sh (case-scoped, `/tmp/r11u192_g`).
- **v11u192repro:**
  - Source env.sh and refuse fenced paths: grid.sh, swm.sh, bnd1.sh.
  - **Do not check:** cmp3.py and recdir.py (readers; cmp3.py hard-codes `/tmp/v11u192_drv/recdir.py` and
    `/tmp/v11u192_g`, both pruned); the gen_*.py case generators.
- **r11u193repro:**
  - Source env.sh (fail closed): every shell driver.
  - Skip fenced rows by `r193_fenced`: predict.sh, rowrun.sh, row.sh, rowdist.sh, ob.sh, case.sh, offcheck.sh (probe
    paths), bvmirror.sh.
  - Read canaudit.sh themselves: probeheads.py and probesub.py.
  - uvmdist.sh needs `$FENCED` exported (four-name check); its strict-comparator default is the pruned
    `/tmp/r11u168_bin`.
  - **No fence check of their own:** switches.sh and grid.sh (the pass's own cases only), sweep.sh (a gate sweep),
    cc.sh (a build script), predict.cpp, tsrefs.cpp and objrefs.cpp (tools).
- **v11u193repro:**
  - Source env.sh (fail closed): every shell driver.
  - `v193_fenced` guards: case.sh, ds.sh, rowrun.sh, rowdist.sh, predict.sh, switches.sh, attr.sh.
  - **No check of their own:** bvmirror.sh (four-name check of `$FENCED` only), sweep.sh (a gate sweep).

**Predictions written before their sweeps, as far as the tree can show:**
- **Pass 192:** the pass-192 firing census, re-run here on the HEAD binary with `R11U192_TRACE` over every non-fenced
  database, reproduces `r11u192repro/evidence/predicted_movers_192.txt` exactly
  ([census192_at_head_vs_predicted.txt](evidence/process/census192_at_head_vs_predicted.txt)). That is 29 databases,
  0 missing, 0 extra, and identical law counts.
  - The census is a function of the law binary and the sources.
  - The measured pass-192 movers at HEAD (swH against sw2) are exactly those 29 plus the UVM coin (MiniAmiq d/t,
    SeqDriver d/t, BuildUVMPkg d; [prediction_vs_measured.txt](evidence/process/prediction_vs_measured.txt)).
- **Pass 193:** its committed `predict.cpp`, rebuilt with its own `cc.sh` and run by its own `predict.sh` over swA,
  reproduces `predict_with_copy_trigger.txt` exactly: 581 lines, 0 differing
  ([predict193_rerun.txt](evidence/process/predict193_rerun.txt)). swA is the `706ab521` state, i.e. pass 193's
  pristine `6ab9f4fb` plus r11u194's byte-neutral refinements.
  - With the COPY trigger stripped, the output reproduces `predict_before_sweep.txt` exactly (442 lines).
  - ibex_pmp is absent from the before-sweep file and present in the COPY file, as the implementer disclosed.
  - The measured pass-193 movers (170: swH against sw3) are all inside the COPY-trigger prediction.
  - Against the before-sweep prediction, the misses are ibex_pmp d/t and the UVM coin rows.
  - The predictor reads only pristine databases, so it could not have seen the law sweep. That it ran before the
    sweep, and that the copy-order law was added after, is the README's own statement; git keeps no timestamps.
- **The cases' first lines** ([case_first_lines.txt](evidence/process/case_first_lines.txt)): every case of the four
  directories (30, 135, 65, 77) carries a `// § law` first line. The claim holds. N10 shows the one law no first line
  names.

**This pass's own prediction** ([prediction_fix199.txt](evidence/fix/prediction_fix199.txt), frozen `chmod 444`):
- It was written at 01:42:39 by [predict199.py](drivers/predict199.py) from the HEAD census traces
  ([census193.sh](drivers/census193.sh), both pass traces) and the HEAD databases. The final fix sweep started at
  01:46:36.
- It names 3 corpus databases (Earlgrey_0_1 d/t UCVARSEL, Rggen d UCOWNER) and 0 probe databases. It also reads 0
  databases where § genForWholeLhsNestedKeep192v fires, so the call-root refinement can move nothing in either
  corpus.
- Positive controls: x07, x08 (UCOWNER), x09 and u06 (UCVARSEL) are predicted and move. Negative controls: u01 and u05
  are not predicted and do not move.
- Measured: 0 real movers, a subset of the prediction. The 8 UVM coin movers are 0 or 4 lines order-blind.

**Operations of this pass, disclosed:**
- **Three fix builds** ran in this worktree's `src/`, each frozen under `/tmp/r11u199_bin` before use. The sources
  were reverted with `git checkout src` after the last. The deliverable carries no `src/` edit.
- **Two fix sweeps were started and stopped** by this pass. Each process was checked by its command line before it
  was killed.
  - One started with a missing `fix.sh` wrapper and was stopped within 20 s.
  - One on fix2.bin was stopped in its surelog stage when w4/s8 showed the user-call variant moving away. Its probe
    stage (0/0/0) is kept as [sweep_swF_fix2_aborted.log](evidence/sweeps/sweep_swF_fix2_aborted.log).
  - The reported swF is fix3 = fix.bin.
- **The census ran twice:** the first (pass-193 trace only) was replaced by the second, with both traces, before the
  prediction was written. A predictor run on the first census's partial traces wrote a file that was deleted unread.
- **Other agents' work:** the main tree's HEAD moved to pass 195 (`7eb6f4b5`) and its `build/slang-uhdm` was rebuilt
  during this pass. Nothing here reads the main tree's files or binary. The live pairs' worktrees were not touched.
- **Resources:** up to three sweeps ran concurrently at `--jobs 3`. The fix builds ran at `-j 1`, and the fresh
  verification build of fix.patch at `-j 2` with 11 GB free. There was no OOM.

## 11. Files

- [fix.patch](fix.patch): § genForWholeLhsCallRootOwner199v, § ucCloneUnnamesOwnerTs199v and § ucCloneUnnamesVarSel199v
  (`git diff 58905f76 -- src`).
- `cases/{A,C,N,O,P,Q,R,S,T,U,V,W,X}/`: 85 cases. O/o04 includes `wr.svh`.
- `drivers/`:
  - environment and states: env.sh, laws.py, mkstate.sh;
  - sweeps: sweep.sh, queue.sh, statecounts.py;
  - cases: case.sh, grid.py, gridall.sh, gridfix.sh, lawsum.py, lawtable.py, fieldscore.py, recaway2.py, dumpaway2.py;
  - composition and changes: compose.py, bytecancel.py, unmask.py, unmaskpos.py;
  - downstream: dscase.py, dsall.sh, dsnet.sh;
  - determinism and UVM: det.sh, ob.sh, obpair.sh, uvmdist.sh;
  - byte mirrors: bvmirror.sh;
  - fix: census193.sh, predict199.py, fixbound.sh, fixjudge.py;
  - process: fencecheck.sh.
  - Drivers copied from r11u194verify say so in their second line.
- `evidence/`: `grid/`, `fix/`, `composition/`, `changes/`, `downstream/`, `uvm/`, `determinism/`, `process/`,
  `residues/`, `sweeps/`, `binaries.txt`.
