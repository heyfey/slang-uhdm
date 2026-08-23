# r10v115 — ADVERSARIAL VERIFICATION of r10uvm115 § `builtinClassLocalUnsupportedBeforeClassPhase115`

**VERDICT: ACCEPT-WITH-FIX.** Every headline number reproduces bit-for-bit from
independently built binaries. One real defect was found and fixed by the
verifier: the shipped `GATES.txt` **spelled the four slang-fenced test names**,
so the pass's own mandatory `canaudit.sh` — run from the pass directory, the
standing rules' own invocation — reported **FENCE-BREACH=4 and exited 6**,
contradicting the `FENCE-BREACH=0` claimed on that very line. Fixed; canaudit
now exits 0. No production source was changed.

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` and `scripts/verify_golden.py` are the authorities.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `8a4b59a` |
| worktrees | `/tmp/wt_v115` (patched), `/tmp/wt_v115pris` (pristine) — both fresh at BASE |
| pristine binary | md5 `61228316cb53458c749fc64dec6df028` — the implementer's exact value |
| patched binary | md5 `22a4739a000c9e1ec68f2a3c1cad4fc0` — the implementer's exact value |
| both frozen | `chmod 555` at `/tmp/v115_bin/{pris,pat}115v.bin` BEFORE any sweep |

## 1. EVERY HEADLINE NUMBER, REPRODUCED INDEPENDENTLY

| claim | implementer | verifier | |
|---|---|---|---|
| pristine binary md5 | `61228316…` | `61228316…` | EXACT |
| patched binary md5 | `22a4739a…` | `22a4739a…` | EXACT |
| goldens patched / pristine / `/bin/false` | 23-0 / 23-0 / 0-23 | 23-0 / 23-0 / 0-23 | EXACT |
| surelog histogram | 937 EQ / 19 NE / 567 REJ / 48 FAIL / 3 NODB / 2 UNTR / 10 DEF / 1 TO / 1 NOUHDM | identical, patched AND pristine | EXACT |
| u2r ×2 modes | 679 / 50 / 2 | 679 / 50 / 2, all four sweeps | EXACT |
| ct8rows surelog (baseline, own pristine) | PASS | PASS | EXACT |
| ct8rows u2r tf + def | PASS | PASS | EXACT |
| byte movers surelog | 9 / 956 | **9 / 956, the same nine paths** | EXACT |
| byte movers u2r | 0 / 1358 | 0 / 1358 | EXACT |
| direction score | 1644 moved / 1644 TOWARD / 0 AWAY | **1644 / 1644 / 0**, per-database 140·246·108·260·122 | EXACT |
| pristine fence | FAMILY 140 in 9 DBs, MIRROR 0, OTHERDIF 18 | **140 / 0 / 18**, per-DB 10·24·8·24·8 ×2 modes | EXACT |
| patched fence | FAMILY 32, MIRROR 0, OTHERDIF 18 | **32 / 0 / 18** | EXACT |
| heads pristine | SimpleUVM 56·56, Scoreboard 56, SeqDriver 62, MiniAmiq 62, BuildUVMPkg 47, Earlgrey 36, Rggen 0 | identical | EXACT |
| heads patched | SimpleUVM **17·17**, Scoreboard **60**, rest unchanged | identical | EXACT |
| head logs byte-identical | SeqDriver, MiniAmiq, BuildUVMPkg, Earlgrey, Rggen | confirmed by `cmp` | EXACT |
| committed head `.cmp` files | — | patched + pristine SimpleUVM/default reproduce the committed files byte for byte | EXACT |
| canaries / ctcan2 | 52-0, 8-0, PASS, PASS | identical | EXACT |
| protected DB md5s | 5 named, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | identical | EXACT |
| boundary MODE=file VIEW=def | 3531 / DIFFER 5 / rejects 138 | **3531 / 5 / 138**, same five arms | EXACT |
| boundary MODE=file VIEW=elab | 3531 / DIFFER 5 / rejects 150 | **3531 / 5 / 150**, same five arms | EXACT |
| canaudit | audited=29 UNCOVERED=0 **FENCE-BREACH=0** | **FENCE-BREACH=4, exit 6** | **FALSE — FIXED** |

`cmds.txt` audit, file by file: 1573 files in each surelog sweep, of which **50
never invoke slang at all** (SURELOG_FAIL / NO_DATABASE / DEFERRED) and the
remaining **1523 name exactly ONE binary path** — the frozen one, and never the
other binary or the main tree's. u2r: 1462 files, 1458 naming one binary. Both
match the implementer's 1523 / 1458 exactly once the never-invoking files are
accounted for.

**Every CMP_EQUAL row of both corpora is untouched in the strongest sense:** all
nine byte movers are `CMP_NOTEQUAL` rows, so no CMP_EQUAL row's database changed
a single byte (947/956 surelog and 1358/1358 u2r byte-identical).

## 2. THE DECODED LAW, RE-DERIVED FROM SURELOG SOURCE

Every citation was checked against the source, not carried forward:

* `CompileDesign.cpp` — modules at `:350-356`, programs at `:353-356`,
  `if (parseBuiltIn()) { Builtin(...).addBuiltinClasses(); }` at **`:358-361`**,
  classes at **`:385-388`**. Packages compile even earlier, at `:340`. **The
  ordering is exactly as claimed.**
* `Builtin.cpp` — `addBuiltinClasses()` at `:291`, `mailbox` at `:303`,
  `process` at `:332`, `semaphore` at `:357`, and the registration
  `design->addClassDefinition(name, def)` under the **SIMPLE** name at `:392`.
* `CompileType.cpp` — `compileVariable`'s `slStringConst` arm at `:336`, the
  final `ref_var` arm at **`:421-431`** (it calls `needLateTypedefBinding(ref)`
  when `ts` is an `unsupported_typespec`), the catch-all that mints
  `unsupported_typespec` named for the written token at **`:1051-1055`**, and
  `result->Instance(component->getUhdmInstance())` at **`:2135-2136`**.
* `ElaborationStep.cpp:102-148` — `bindTypedefs_` collects **only** TypeDef maps
  (file / package / module / program / class). `process` is not a typedef, so
  the repair can never reach it. **Confirmed.**
* `UhdmWriter.cpp` — `lateBinding` at `:3294`, and the `uhdmref_var` refusal at
  **exactly** `:3315 :3324 :3335 :3344 :3387 :3397 :3418 :3426` — all eight
  line numbers verified.

## 3. BREAKING THE LAW — SEVEN NEW ARMS, 0 REGRESSIONS

Seven purpose-built arms (`ARMS.txt`) cover every declaration shape the brief
names that the implementer's four grids do **not** reach, scored against golden
in **both views** with `cmp115.py` (a multiset join on view / site / owner /
line:col / name; payload = declaration kind + typespec kind + typespec name +
typespec instance; **no span, no file** — our objects carry an empty `VpiFile`).

| arm | what it tests | cells differing PRISTINE | PATCHED | REGRESSIONS |
|---|---|---|---|---|
| `v115_a.sv` | `$unit` free function, package-local typedef of the builtin, STATIC in-body method, OUT-OF-BODY STATIC method, `mailbox #(int)`, NAMED blocks, PROGRAM initial + task, INTERFACE initial + function, `always @(*)`, `always_comb`, named initial block | 33 | 16 | **0** |
| `v115_b.sv` | `process::self()` as initialiser / assignment Rhs / condition / argument; `p.status()`, `p.kill()`, `p.await()`; fixed array, queue, dynamic array of handles | 10 | 6 | **0** |
| `v115_c.sv` | a MODULE INSTANTIATED INSIDE A GENERATE BLOCK | 10 | 5 | **0** |
| `v115_d.sv` | THE CONTROL — user classes named `process` / `semaphore` / `mailbox` | **0** | **0** | **0** |
| `v115_e.sv` | a class declared inside a MODULE (in-body + out-of-body), a NESTED class, for-loop / case-item / while / fork block items in both a class method and a module initial | 20 | 10 | **0** |
| `v115_f.sv` | nested for-generate, generate-block TASK, FORK inside a nested generate, if-generate inside a for-generate | 5 | 3 | **0** |
| `v115_g.sv` | THE MIRROR HUNT — virtual class, abstract class, parameterised class (in-body + out-of-body) | 6 | 3 | **0** |

Every remaining `STILL` cell is a **listing-count** difference (golden lists a
body local under both the subroutine and its `begin`; we list it once — residue
R6) or a recorded residue; in every one of them the declaration KIND, the
typespec KIND, its NAME and its INSTANCE all equal golden's.

### THE SHAPES THAT NEWLY GO TO GOLDEN (eleven, none previously measured)

PROGRAM `initial` local · PROGRAM task local · INTERFACE `initial` local ·
INTERFACE function local · `always @(*)` body local · `always_comb` body local ·
NAMED `initial` block local · NAMED block inside a package function ·
OUT-OF-BODY **STATIC** class method local · out-of-body method of a
**module-nested** class · out-of-body method of a **parameterised** class ·
`for`-loop / `case`-item / `while` / `fork` block items of a module `initial` ·
and the `$unit` free-function local (kind and typespec go to golden; only our
pre-existing declaration SPAN differs, see R8).

### THE FENCES THAT HOLD (no MIRROR found anywhere)

IN-BODY class method — plain, **static**, **virtual**, **abstract**,
**parameterised**, **module-nested** and **nested-class** — all keep `class_var`
+ an unnamed `class_typespec`, matching golden. A NAMED block, a `for`-loop body
and a `case`-item body **inside** an in-body class method keep it too. The
scoped `std::process` spelling, arrays, class properties and package/module
variables are untouched. The CONTROL arm `v115_d.sv` differs from golden in
**zero** cells before and after.

### THE SUSPECTED UNDER-FIRE, REFUTED BY MEASUREMENT

`inGenScopeChain115` walks the **whole** UHDM parent chain, so a module
instantiated inside a generate block looked like it should be wrongly fenced
out: in the elaborated listing that instance's chain runs through a `gen_scope`,
yet its body is compiled in Surelog's MODULE pass and golden degrades it.
**Measured on `v115_c.sv`: it does not happen.** Golden gives `ref_var +
unsupported` to `work@mc_top.gblk[0].u_leaf`'s `initial` local and to the leaf
module's task local, and the patched build gives exactly that, in both views —
the gen_scope is not on the chain the block-item site reads. `v115_f.sv` then
shows the fence still holding correctly at generate depth 2, for a
generate-block TASK and for a FORK inside a nested generate.

## 4. THE ONE DEFECT, AND THE FIX

`bash canaudit.sh canaries.sh ctcan2.sh`, run from `tools/probe/r10uvm115repro`
exactly as the standing rules require, **exits 6 with FENCE-BREACH=4** on the
patch as shipped. `canaudit.sh` greps every file of its own directory except
itself and `README*.md` for the four slang-fenced test names; the shipped
`GATES.txt` spelled all four on the very line that claims `FENCE-BREACH=0`.

The fix removes the four names from `GATES.txt` and records what happened.
Nothing else changed; after it, `canaudit.sh` exits **0** with
`audited=29 UNCOVERED=0 FENCE-BREACH=0`. **No production source was touched by
the verifier** — `src/` and `include/` in `r10uvm115.verified.patch` are byte
for byte the implementer's.

## 5. CLAIMS CORRECTED

**(a) The MODE=dir nondeterminism claim is TRUE, but its stated evidence is
not.** The implementer wrote that *"eight runs of the PRISTINE binary alone over
[`r10uvm88repro`] produce TWO distinct dumps, and adding four PATCHED runs
produces NO THIRD dump."* Re-run here, **8 pristine runs produced ONE dump** and
the 4 patched runs produced a **second** — the opposite of the shipped
framing, and on its face a conviction. Pushed to **40 pristine runs**, the
pristine binary produced that same second dump once (1 in 40). The flip is real
and rare, the patched binary's output set is a **subset** of the pristine
binary's, and the differing dump is a single `vpiTaskFunc` list-order move of
`\_function: (p3::base3::oob_base)` and nothing else — RESUME §9's documented
macro-buffer ordering flip. No file in that directory contains the token
`process`, `semaphore` or `mailbox`, so the law cannot reach it. **Conclusion
upheld; the sampling sentence should not be relied on.**

**(b) "We inherit the refusal for free" is loose, but the corpus number behind
it is right.** Our emitter does not run Surelog's `lateBinding`, so it does not
"inherit" anything; it simply stops binding these references because the
declaration is no longer a `class_var`. Measured directly on SimpleUVM/default,
over every reference named `p` / `p_` / `phase_runner_proc` / `m_reg_process`:

| actual bound | golden | pristine | patched |
|---|---|---|---|
| `class_var` | 27 | 37 | **27** |
| `logic_net` (the implicit nets) | 5 | 0 | **4** |
| unbound (`NULL`) | 87 | 82 | **88** |

`class_var` lands **exactly** on golden's 27; the single missing `logic_net` and
the single extra unbound reference are the **same one object** — `work@top.p`,
which is residue R0 and the new head. The arithmetic closes.

## 6. RESIDUES THE PASS DID NOT NAME

* **R8 (new) — `mailbox #(int)` and every PARAMETERISED builtin-class
  declaration is NOT covered.** Golden degrades it like any other
  (`ref_var + unsupported_typespec 'mailbox'`, instanced at the declaring
  package); we keep `class_var + class_typespec`. Conjunct 2 rejects it because
  `mailbox #(int)` parses as a `ClassName`, not an `IdentifierName`. Measured on
  `v115_a.sv` cells `so_mi` (out-of-body static method) and `pf_mi` (package
  free function), both views. **Zero corpus witnesses** — the patched fence's 32
  remaining FAMILY cells are all `process`, so widening here would be
  evidence-free. A miss, never a regression.
* **R9 (new) — the `$unit` free-function local's declaration SPAN.** Golden
  spans it over the TYPE token (`4:3-4:10`), we span it over the NAME
  (`4:11-4:15`); for the same declaration in a PACKAGE function golden agrees
  with us. Pre-existing (identical in the pristine build), and judge-invisible —
  no generated `Compare` reads a span.
* **R10 (new, cosmetic) — `scoreall115.sh` redirect asymmetry.** The golden dump
  is taken as `uhdm-dump "$G" 2>&1 > file` (stderr goes to the terminal, not the
  file) while the two of ours are taken through a pipe that does capture stderr.
  Harmless here — `score115.py` drops the banner and any warning would be
  identical on both of our sides — but the two orders should match.
* Nothing was found to contradict the pass's own R0–R7.

## 7. THE INSTRUMENTS HERE

`v115_a…g.sv` (see `ARMS.txt`) and `cmp115.py`. They are driven by the
implementer's own `grid115.sh` / `ct115cen`, unchanged, so both sides are built
by the same instrument and every command is echoed with its own `rc`.
