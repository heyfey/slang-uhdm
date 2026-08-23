# r10v76 — adversarial verification of r10earl76 (§ genScopeProcLoopCtrlNoFold76)

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduces bit for bit from binaries this verifier built itself — the two md5s,
the 36-line head byte-identical to the committed log, both new head counts, the
four-cell corpus census in both modes, all four grid scores, every gate, every
canary, both boundary tallies. The decoded law is right about WHY Surelog
refuses and its Surelog line references are accurate.

**But the law as shipped is stated in terms of a PROXY (position in a generate
scope) rather than the mechanism it decodes, and the proxy OVER-FIRES on legal
SystemVerilog in seven measured configurations.** In each of them golden
*folds* and the shipped patch emits a `ref_obj` instead — a `VpiType` flip, the
first field `BaseClass::Compare` tests, from a state that differed from golden
only by a missing `int_typespec`. A further judge-visible field, the minted
`enum_const`'s `VpiDecompile`, is wrong for every decimal- and octal-based
package parameter. `/tmp/r10earl76.verified.patch` fixes all of it.

**The fix changes not one byte of either corpus.** All 956 surelog databases
and all 1358 uhdm2rtlil databases are byte-identical between the shipped binary
and the verified one except the documented Scoreboard/default coin; the two
Earlgrey databases match exactly (`dd7409c8b813` / `05adcb77cebe`). So every
corpus claim the implementer makes carries over unchanged and is re-measured
here on the verified binary.

* base `b494676`; `results/*.csv` READ ONLY and untouched; **no row converted**
* pristine `0488d7b62f80e7aecab313abd9320510`, shipped `34cf9797d54de8af35fab279daffa696`
  (both == the implementer's), verified `8712a16593e58109e339eceee9aa770f`
* evidence: `GATES_V76.txt`, `GRIDS.txt`, `GOLDEN_TABLE_V76.txt`,
  `SURELOG_DECODE_V76.txt`, `ARMS_V76.txt`, and the eight `.sv` arms here

---

## 1. What was reproduced, from the verifier's own builds

Both worktrees were created fresh at `b494676`, both binaries built `-j 2` and
frozen `chmod 555` before any sweep, `SLANG_UHDM` exported explicitly to each,
and **every one of the 1462 + 1573 `cmds.txt` files per sweep audited by binary
PATH — 0 name the main-tree binary, 0 name the wrong frozen binary.**

| claim | reproduced |
|---|---|
| pristine md5 == the main tree's own build at b494676 | yes, `0488d7b6…` |
| patched md5 `34cf9797…` | yes, exactly |
| head before: 36 lines, 1 head, identical in both modes | yes; and byte-identical to the committed `HEAD_BEFORE_default.cmp` (diff 0) |
| head after: 11664/1 default, 11404/1 testflags | yes |
| every other named row's head unchanged | yes (SeqDriver 32/1, SimpleUVM 565/1, Scoreboard 565/1, MiniAmiq 32/1, BuildUVMPkg 47/1, Rggen 0/0) |
| R0 = `work@top_earlgrey.u_spi_device.u_fwmode` module_inst, both modes | yes |
| u2r 679/50/2 both modes, 0 differing rows | yes, against the committed baseline AND my own pristine sweep |
| surelog 0 differing rows over 1588, histograms identical | yes; Earlgrey stays CMP_NOTEQUAL |
| movers 0/1358 and 3/956 | yes; Scoreboard/default convicted as the coin by a neutral control — the PRISTINE binary alone lands on both sweep hashes across three runs (`508bcd0b88c0`, `0069d49f0350`, `508bcd0b88c0`) and the dumps differ by 92 raw lines and 0 order-blind |
| census TO-GOLDEN 4 / AWAY 0 both modes, calibration all STILL-RIGHT | yes: 182545 and 247637 calibration keys, 185773 and 249393 scored keys, the same four cells |
| canaries 52 + 8, ctcan2 PASS x2, canaudit audited=29 UNCOVERED=0 | yes |
| five protected databases byte-identical, both pins | yes |
| boundary WIDE 3484/10, DIR 1508/12 | yes — 3491/22 and 1509/14 with this verifier's eight extra arms folded in, and the extra differing cells are exactly those arms |
| the Surelog decode (`CompileStmt.cpp` :662/:680/:697/:829/:2822) | yes, verbatim; `compileForLoop`'s signature genuinely has no `instance` parameter |

## 2. What broke — the shipped law's over-fire

The decode says the refusal happens because *"a generate block is its own
`DesignComponent` and its `param_assigns` hold only the block's own
localparams"*. The law then tests **where the read is** (a gen-scope process's
for statement or loop control) and never **where the import is**. Put the
`import` on the generate block and that block's own `param_assigns` DO get the
parameter with `VpiImported()` set, the component-level arm at
`CompileExpression.cpp:2915-2977` fires, **and golden folds.**

Measured against real Surelog, one `for` CONDITION and one `repeat` COUNT per
row (`a3_imp76.sv`, `a6_impx76.sv`, `a7_hdrimp76.sv` — the full table is in
`GOLDEN_TABLE_V76.txt` §1):

| where the providing import is declared | golden | shipped patch |
|---|---|---|
| module body `import p::*;` | `ref`+`enum_const` | matches |
| **module header** `module m import p::*; #(...)` (the corpus's own shape) | `ref`+`enum_const` | matches |
| module body `import p::P;` (explicit) | `ref`+`enum_const` | matches |
| **generate block** `import p::*;` | **`constant`** | **`ref_obj` — AWAY** |
| **generate block** `import p::P;` | **`constant`** | **`ref_obj` — AWAY** |
| **module AND generate block, same package** | **`constant`** | **`ref_obj` — AWAY** |
| module imports p, gen block imports q — the read of q's Q | **`constant`** | **`ref_obj` — AWAY** |
| module imports p, gen block imports q — the read of p's P | `ref`+`enum_const` | matches |
| **inside the process's own `begin` block** | **`constant`** | **`ref_obj` — AWAY** |
| **compilation-unit (`$unit`) import only** | **`constant`** | **`ref_obj` — AWAY** |
| qualified `p::P`, any of the above | `constant` | matches (the `::` fence) |

and one more home, `a1_homes76.sv` row `gp_a`:

| home | golden | shipped patch |
|---|---|---|
| **a generate block inside a `program`** | **`constant`** + `int_typespec` | **`ref_obj` — AWAY** |

Surelog gives a program's generate block no `DesignComponent` at all: golden
emits **no `gen_scope_array` under a `program`** and hoists the block's
`initial` straight into the program body, where the substitution happens.
`if`/`for` generate constructs are legal program items (IEEE 1800 A.1.7
`program_generate_item`), so this is legal SV, not a rejected shape.

### The judge-visible value bug

`enum_const::Compare` reads `VpiName`, `VpiDecompile` and `VpiSize`. The
encoder copied from law 24 keeps the **written** based literal for every base;
golden keeps it only for `'h` and `'b` (`a5_ctrl76.sv`, one row per base):

| package parameter | golden `VpiDecompile` | shipped patch |
|---|---|---|
| `parameter bit [7:0] H8 = 8'hA5` | `8'hA5` | `8'hA5` |
| `parameter bit [7:0] B8 = 8'b10100001` | `8'b10100001` | same |
| `parameter bit [7:0] D8 = 8'd12` | `12` | **`8'd12`** |
| `parameter byte DS8 = 8'sd12` | `12` | **`8'sd12`** |
| `parameter shortint SI = 16'sd300` | `300` | **`16'sd300`** |
| `parameter longint BIG = 64'd4294967296` | `4294967296` | **`64'd4294967296`** |
| `parameter bit [7:0] O8 = 8'o17` | `15` | **`8'o17`** |

## 3. The fix (three parts, all minimal, all gated)

**(a) the import-site fence.** Walk out from `currentGenBlkScope`; fire only
when **no scope between the read and the module body provides the name AND the
module body itself does** — the innermost provider decides. That single
predicate reproduces all eleven measured import configurations, the
compilation-unit one (outside the body, so it folds) included.

**(b) the based-literal encoder.** `'d` and `'o` fall through to the plain
decimal default; only `'h` and `'b` keep the written text.

**(c) the program fence.** A gen-scope process whose enclosing `InstanceBody`
is a `DefinitionKind::Program` is not a home of this law. An **interface is
not** fenced: golden builds a real `gen_scope` there and refuses exactly as in
a module (`a1_homes76.sv` rows `gi_a`/`gi_b`, TO-GOLDEN).

## 4. Result

| arm | before the fix | after |
|---|---|---|
| `a3_imp76.sv` | 6 cells AWAY from golden | 0 |
| `a6_impx76.sv` | 6 cells AWAY (three shapes) | 0, TO-GOLDEN 2 |
| `a1_homes76.sv` (program) | 2 cells AWAY | 0, TO-GOLDEN 17 |
| `a4_val76.sv` | TO-GOLDEN 9, 6 wrong decompiles | **TO-GOLDEN 14**, 1 sideways |
| `a5_ctrl76.sv` | — | **TO-GOLDEN 7** |
| `a7_hdrimp76.sv` | — | **TO-GOLDEN 3** (the corpus's header-import shape still fires) |
| the implementer's four arms | 23 / 16 / 3 / 5 | **23 / 16 / 3 / 5, unchanged** |

Across all twelve arms: **TO-GOLDEN 97, AWAY-GOLDEN 0, MOVED-WRONG 0,
NOGOLD-MOVED 0, MOVED-SIDEWAYS 1** (that one is `int'(7.0)`, V-R3). Corpus:
**TO-GOLDEN 4 / AWAY 0 in both modes**, 0 bytes changed against the shipped
binary.

## 5. Residues found here, ranked

**V-R1 — a gen-scope `initial` or `final` body is a WHOLE FURTHER NO-FOLD
CONTAINER, and the shipped comment says the opposite about part of it.** The
header comment claimed *"golden FOLDS in the `while`, `do…while`, `repeat`,
`foreach` and `forever` bodies"*; `g1_gsfor76.sv` **contains no `forever` at
all**, and the claim is false. `a5_ctrl76.sv` and `a8_init76.sv` name the real
discriminator — the **procedure kind**:

* gen-scope `always_comb` / `always @(posedge clk)` / bare `always` → golden
  folds everywhere outside the for statement and the three loop controls;
* gen-scope `initial` and `final` → golden **refuses at every position in the
  body**: a plain statement, an `if` condition, a one-statement
  `initial x = NB`, a `forever` body (plain and `@(posedge)`-controlled), and a
  delay-controlled `#5 x = x + NB;`.

`compileStmt`'s `paFOREVER` arm (`CompileStmt.cpp:513`) passes `instance`
through, so the null must originate one level up, where the *process* is
compiled. **Both binaries fold in all seven cells** — an under-fire, a residue,
never a regression — and 0 corpus cells. The source comments now state this.

**V-R2 — the gen-scope TASK, as well as the function.** The implementer's R1
names the gen-scope function; `a1_homes76.sv` row `gh_b` shows a **task**
declared in a generate block behaves the same way (golden refuses, both
binaries fold). Same hole, same `!currentTf`, same `ModuleEmit.cpp:14618`
ordering.

**V-R3 — a package parameter whose initialiser Surelog cannot evaluate.**
`parameter int CST = int'(7.0)`: golden emits the `ref_obj` with **no
`Actual_group` at all**, and we bind an `enum_const 7`. `real` and `string`
parameters leave both binaries with an unbound ref where golden binds. A
value-model residue, not this law's; deliberately not modelled here.

**V-R4 — the `--elabuhdm` view re-points an INTERFACE's fresh `enum_const` at a
shared `constant`.** 5 cells on `a1_homes76.sv`; the ref's own `VpiType` now
matches golden where the pristine binary had a `constant`, so it is not worse,
but it is not right. Elab-view only.

**V-R5 — the `case` EXPRESSION fold is unstamped.** `case (NB)` in a gen-scope
process: golden folds **with** an `int_typespec`, both binaries fold bare
(`a2_pos76.sv`). Same family as earl75's R4.

The implementer's own R0–R5 are carried forward unchanged; R0
(`u_fwmode`'s `tx_data_i`, `logic_var` vs `logic_net`) was re-measured here and
stands.

## 6. Reproduction

```bash
# an arm: Surelog golden + both frozen binaries, both views, censused
CSCEN76=<cscen76> NORM76=../r10earl76repro/norm76.sh PRIS=<p> PATCHED=<q> \
  ../r10earl76repro/arm76.sh a3_imp76.sv <outdir>
python3 ../r10earl76repro/score76.py <outdir>/g.n <outdir>/o.n <outdir>/q.n 40 --judged
python3 ../r10earl76repro/goldtbl76.py <outdir>/g.n <outdir>/o.n <outdir>/q.n NB
# the boundary (a COPY of tools/probe, no path filter; the fenced tests match 0 files)
PROBE_ROOT=<copy> PATCHED_BIN=<q> PRISTINE_BIN=<p> STAGE=<own> \
  ../r10earl76repro/vwide76.sh <file-list> <prefix>
```
