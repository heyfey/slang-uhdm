# r10vbuvm28 — ADVERSARIAL VERIFICATION of r10buvm28 (§ `enumNoBaseTypespecZeroBits28`)

**VERDICT: ACCEPT WITH FIX.** The law is real, decoded correctly from Surelog
and UHDM source, and confirmed against golden on 14 independently written
grids. Every headline number in the implementer's report was reproduced
bit-for-bit from binaries this verifier built itself at BASE `6c74d2a`.

**But the rule as submitted was not the rule the report describes.** It did not
only override the digits of a constant — where every earlier fold road
declined, it *created* a fold, turning one of golden's own `sys_func_call`s
into a constant. Measured on `$bits(<instance>.<member>)` through an interface
or module instance: golden keeps the call, pristine kept the call, the
submitted patch minted `0` / `8` / `0` / `0` and destroyed golden's
`hier_path`. **20 def + 22 elab BROKE cells** on legal SV
(`gv28_h_hier.sv`, `gv28_g_last.sv`). Corpus population **0**, which is exactly
why only a wide, independently written arm could see it.

A **2-line gate** fixes it (`src/ExprEmit.cpp`, the substitution site only) and
costs the corpus **nothing**: the shipped binary's `BuildUVMPkg` databases are
byte-identical to the submitted patch's, the head still goes 32 → 17 in both
modes with the same cmp md5, and every arm's `BROKE` is **0**.

MEASUREMENT ONLY. `uhdm-cmp` and `scripts/verify_golden.py` are the judges.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours. slang was **NOT** patched.
`results/*.csv` were **READ ONLY** and **nothing was promoted; no corpus row
converted**. `GOLDEN_DEFER` UNSET.

| | |
|---|---|
| BASE | `6c74d2a` |
| worktrees | `/tmp/wt_vbuvm28` (patched+fix), `/tmp/wt_vbuvm28pris` (pristine), `/tmp/wt_vbuvm28walk`, `/tmp/wt_vbuvm28null` (controls) |
| pristine md5 | `26fbd8c01ce0de4b3e257726f388de86` — **reproduced** (and equal to the main tree's build at `6c74d2a`) |
| submitted-patch md5 | `3d2fec8e71e6490ef8bc4c2acd8bde03` — **reproduced** |
| walk-only control md5 | `b40638519705c4aec078516a7c13ee30` — **reproduced** |
| **shipped md5** | `84c855c12bc9ba13a9589b2d0e394039` (submitted patch + the gate) |
| `BuildUVMPkg` cmp md5, both modes | `9b31531212f75a5a…` → `4b761630ccd5bbee…` — **reproduced**, and the fix does not change it |
| deliverable | `/tmp/r10buvm28.verified.patch` |

## 1. WHAT WAS REPRODUCED, BIT FOR BIT

Both binaries built here from fresh worktrees hash to the implementer's md5s
exactly. So does the walk-only control, which is independent evidence that the
same edit was reconstructed.

Every gate re-run from the verifier's own frozen binaries and own workdirs,
`SLANG_UHDM` exported per binary and **every** `cmds.txt` audited BY PATH
(6070 files; one distinct binary per workdir; zero name a main-tree binary):
goldens 23/0 and `/bin/false` 0/23; u2r 679/50/2 both modes with **0 differing
rows** against the committed baseline and against pristine, and **0 byte movers
/ 1358**; surelog 937/19 with **0 differing rows over 1588**; heads unchanged
except `BuildUVMPkg` 32 → 17; canaries 56/9 changed=0, ctcan2 both PASS,
canaudit audited=33 UNCOVERED=0 FENCE-BREACH=0, pins SAME=10 MOVED=0 with
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a`. Full list:
`GATES.r10vbuvm28.txt`.

**The corpus effect, measured exhaustively rather than sampled.** Byteverify
says only two databases move, so the whole corpus change is inside them. Their
whole-dump path-normalised diff against pristine is **exactly 8 lines**: two
constants at `uvm_pkg.sv:58248:20-36` and `:58283:20-44`, `vpiDecompile` /
`UINT` **32 → 0**. Golden is **0** at both spans. That is 4 cells (2 spans × 2
modes), **all TO-GOLDEN, 0 AWAY**, and provably nothing else.

**The law itself** was re-derived from source, not taken on trust:
`ExprEval::size`'s `uhdmenum_typespec` case leaves `bits` at 0 and never sets
`invalidValue` when `Base_typespec()` is null
(`~/git-repos/UHDM/templates/ExprEval.cpp:1461-1467`), `size(nullptr)` returns
0 the same way (`:1272`), and Surelog only ever builds that base from a written
one (`CompileHelper.cpp:761`, `:797-804`; the inline-anonymous road
`CompileType.cpp:1327-1332` makes the ref with a null actual). A union takes
the MAX (`ExprEval.cpp` `uhdmunion_typespec`), a struct SUMS, and — the detail
that makes the patch's `isFloating() → 32` correct rather than a bug —
`uhdmreal_typespec` is **32**, not 64 (`:1304`).

**The composition law holds on golden**, measured over 14 grids: base-less enum
0; through an alias 0; inline-anonymous 0; negative-valued 0; every explicit
base unchanged (`bit[0:0]` 1, `logic signed [7:0]` 8, `byte` 8, `shortint` 16,
`int`/`integer` 32, `longint` 64, a typedef base 5, `time` kept);
`struct packed {e_bare; bit[7:0]}` 8; `{e_bare; e_bare}` 0; nested struct 12;
`union packed {e_bare; int}` 32 (max); unpacked union 8; `e_bare[3:0]` 0;
`struct packed {e_bare[3:0]; bit}` 1; every array shape of a base-less enum 0;
`struct {e_bare a[4]; byte}` 8. `$size`, `$high`, `$clog2`, enum MEMBERS and
every non-enum control are untouched.

## 2. THE REGRESSION, AND THE FIX

`bitsEnumNoBaseValue28` ends with a fall-through `else { t = a.type; }`, giving
the law an answer for argument shapes **no existing fold road owns**. The
answer lands on `staticBits9`, whose `if (staticBits9)` branch MINTS A
CONSTANT — so a site where the emitter used to fall through to
`MakeSys_func_call`, which is *also golden's answer*, starts folding.

```
                    golden          pristine        submitted patch
$bits(u_if.es)      sys_func_call   sys_func_call   constant 0      BROKE
$bits(u_if.ss)      sys_func_call   sys_func_call   constant 8      BROKE
$bits(u_if.ea)      sys_func_call   sys_func_call   constant 0      BROKE
$bits(u_sub.sv)     sys_func_call   sys_func_call   constant 0      BROKE
$bits(u_if.vv/ii)   sys_func_call   sys_func_call   sys_func_call   ok
$bits(u_sub.sw)     sys_func_call   sys_func_call   sys_func_call   ok
```

Golden keeps `$bits(<instance>.<member>)` for **every** member shape tried,
enum or not, interface instance or module instance. The fix is the gate
`(staticBits9 || (cv && cv.isInteger()))` — literally "this site was already
going to mint a constant", those being the two mint branches immediately below
it. Details, costs and the full arm table: `THE_FIX.r10vbuvm28.txt`.

## 3. TWO CORRECTIONS TO THE IMPLEMENTER'S REPORT

**(a) `g22.sv` is not the type walk.** Four binaries decide it:
`v4_type.sv` moves ONLY under the value substitution (walk == null == pristine)
— a clean FIX, `$bits(m_nb)` 32 → golden's 0. `g22.sv` moves under the patch,
under the walk-only control **and under a NULL EDIT** (200 unreachable
`extern "C"` functions), which lands on a *third* hash. The moving values are
three garbage constants that shift by a constant offset (+4096 for the patch,
+16384 for the null edit) where golden emits a `string_typespec` / `int_typespec`
and no constant at all — the unchecked `ct.as<FixedSizeUnpackedArrayType>()` at
`src/TypeEmit.cpp:10359` applied to the associative arrays of
`typedef int ka_str_t[int];`. It is **address-derived UB**, it moves for any
binary-image change, and it reaches no corpus database.
See `ATTRIBUTION.r10vbuvm28.txt`.

**(b) The shipped ARMS/GATES numbers are the verifier's.** The implementer's
`ARMS.r10buvm28.txt` and `GATES.r10buvm28.txt` describe the **ungated** binary
and are stale for the arm columns (their gate numbers still hold — the fix
changes no corpus cell). `ARMS.r10vbuvm28.txt` and `GATES.r10vbuvm28.txt`
describe what is actually shipped.

## 4. RESIDUES THIS VERIFICATION MEASURED

Ranked; all corpus population 0 unless stated.

1. **R0 (the implementer's, CONFIRMED independently).** `uvm_pkg.sv:58249`.
   Golden's `vpiRhs` is an `operation` `vpiOpType:67` (cast) spanning
   `58249:17-58`, carrying `vpiTypespec → ref_typespec → enum_typespec
   uvm_tlm_command_e`, whose one operand is the streaming `operation`
   `vpiOpType:72` at `58249:45-56`. We drop the cast wrapper entirely: our
   `vpiRhs` IS the stream op, and its span is `58249:46-55` — one column narrower
   on each side, a second sub-residue in the same statement. **Corpus population
   4 cells, `BuildUVMPkg` only.** This is the current head (17 lines, one head,
   both modes byte-identical).
2. **R-G22RANGE / the UB cast** (`src/TypeEmit.cpp:10359`). Every pass that
   changes one byte of the binary pays a boundary mover here, and the value it
   emits is meaningless. A checked cast would retire it permanently.
3. **R-ELABSEG — a SEGFAULT on legal SV, pre-existing.** `--elabuhdm` +
   `$bits(<variable of a PACKAGE unpacked-array typedef>)` crashes both
   binaries; 17 of the 9676 boundary cells are rc=139, symmetric, and one of
   them is a previous verifier's own `seg19.sv`. Minimised to 10 lines in
   `SEGFAULT.r10vbuvm28.txt`. `verify_golden.py` files rc=139 as
   `SLANG_REJECT`, so it is invisible to the CSV gates.
4. **R-HIERKEEP** (created by this verification's own fix, deliberately).
   `$bits` of a dynamic array / queue / associative array of a base-less enum,
   or of a struct containing one, is golden's **constant** and stays our
   `sys_func_call`: 25 arm cells the ungated rule would have fixed. Retiring it
   needs the *keep/fold* decision decoded, not the value — which is the same
   missing decode as § `bitsOutOfBlockNoReduce95`.
5. **R-ENUMCONCAT** (new, measured here). `$bits({e1, e2})` over base-less
   enums is golden **0** (the `vpiConcatOp` arm of `ExprEval::size` sums its
   operands) and ours **64**; `$bits({e1, b1})` is golden **1**, ours **33**.
   The law does not reach the concat road.
6. **R-ENUMPARAM** (the implementer's, confirmed). An elaborated `localparam`'s
   two copies now read `0` and `32`; golden has `0` twice. Half fixed.
7. **R-DOTTED / R-ENUMDOTTED**, **R-CONCATOVER**, **R-BOUNDEDQ**,
   **R-TRAILMEM**, **R-LITARG** — unchanged, not re-measured here.

## 5. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `v3run.sh` | three-way arm runner (golden / pristine / candidate), mirrors `verify_golden.py`'s `default` invocation exactly, both views, records rc |
| `vscore28.py` | **VIEW-GENERAL** scorer: span-keyed **multiset** (never a last-writer dict), payload = kind + VpiName + vpiDecompile + vpiValue + vpiOpType + `#Path_elems` + path-elem kinds/names |
| `vlist28.py` | the same load, printed per span, for reading a grid by eye |
| `vbound28.sh` + `vbcell28.sh` | the wide boundary: no path filter, `.sv` AND `.v`, per FILE **and per DIRECTORY**, both views, fd-3 list, children `</dev/null`, rc per cell, PROCESSED asserted, fenced names skipped and counted, sharded J ways |
| `vpredict28.py` | mover predictor that reads **PRISTINE artifacts only** (the pristine sweep's `cmds.txt` source lists + the corpus sources), so the prediction cannot be contaminated by the measurement |
| `gv28_a_compose.sv` | composition: struct/union/packed/unpacked/array/alias/nesting |
| `gv28_b_homes.sv` | every home a `new[]` can live in and every `new[]` size spelling |
| `gv28_c_edges.sv` | where slang's `EnumTypeSyntax::baseType` and Surelog's `Base_typespec` could disagree, plus 24 must-not-move controls |
| `gv28_d_reach.sv` | argument shapes where the patch's typespec pick could disagree with `compileBits` (calls, casts, concats, replications) |
| `gv28_e_aggr.sv` | aggregate multipliers, 3 instances, generate block, `foreach` |
| `gv28_f_grid.sv` | 37-shape KEEP/FOLD grid |
| `gv28_g_last.sv` | class type arguments, constraints, virtual interface, function returns — **found the regression** |
| `gv28_h_hier.sv` | `$bits` through an instance — **isolates the regression to 7 rows** |
