# r11v174 — adversarial verification of r11u174: every headline number reproduced bit for bit; one break found and fixed (§ elabStructMemberOpFoldUnlocated174 unlocated the fold of a member read straight off a PACKAGE parameter, which golden keeps located: § mopPkgBaseReduces174v, `R11V174_MOPPKG_OFF`); the fix moves no corpus row and no probe case; verdict ACCEPT-WITH-FIX

Base `31739f79` (branch matrix-1.87, pass 169). Implementer's patch `r11u174.patch` (md5 `9cde048e57dde74ec1a082a00173fc9e`)
applied clean on fresh worktrees; the verified patch adds one refinement in `src/ParamEmit.cpp` (the § token
`mopPkgBaseReduces174v`, inside § elabStructMemberOpFoldUnlocated174's member-access branch), this directory and the
regenerated `tests/LAWS.md`. No file under `results/`, `tests/probe/` or `third_party/` is touched; TypeEmit,
ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main and include/ are untouched; net binding is untouched.

## Binaries (every one built here with `-j 2`, system deps, frozen `chmod 555` before any measurement)

| name | what | md5 |
|---|---|---|
| pris | worktree build of `31739f79` | `5f356bace7feda3ba46382e2b63ac365` (= the main tree's pristine) |
| law | `31739f79` + r11u174.patch | `7e22bcccbe35b22fc6f331bf433fb032` (= the implementer's `law9`: the patch reproduces its binary) |
| law2 | `31739f79` + the verified patch | `9cf82ac0ddcdb56b16e7a80ece164079` |
| strictcmp | `build/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` (= the main tree's) |

Three gate sweeps (`tests/sweep.sh --jobs 3`, workdirs `/tmp/v11u174_sw{P,L,M}`, same-length names; downstream run one
sweep at a time). In each, all 3273 slang lines of the 3323 corpus `cmds.txt` name that sweep's frozen binary
(audit in evidence/sweep_*_summary.txt and this README). `GOLDEN_DEFER` unset; every golden served from the cache.

## 1. The implementer's numbers, reproduced

| axis | pristine (P) | r11u174 (L) | verified (M) |
|---|---|---|---|
| probe | EQUAL 2755 / STRICT_NOTEQUAL 1332; regressions=0 conversions=0 changes=0 | EQUAL 2783 / 1304; regressions=0 **conversions=28** changes=23 | identical csv to L |
| surelog | 446+34 / 443+31 (480/3 + 474/3); 0/0/0 | regressions=0 conversions=0 changes=2 | identical csv to L |
| uhdm2rtlil | 777+26 both modes (803/1); 0/0/0 | CMP_EQUAL 779 both modes; regressions=0 **conversions=4** changes=12 | identical csv to L |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, not excused 0 | same; downstream.csv identical to P's | same; downstream.csv identical to P's |
| canaries (vs the base's results/) | canaries.sh ok=52 + ok=16; ctcan2 ok=58 PASS, ok=2 PASS | same | same |

Every changed row, P -> M (evidence/rowdiff_pristine_vs_verified.txt, 69 lines = 2 surelog + 16 uhdm2rtlil + 51 probe):

    struct_param_field_shift,default,CMP_EQUAL,,,equal              (was STRICT_NOTEQUAL differ:fullname(5))
    struct_param_field_shift,testflags,CMP_EQUAL,,,equal            (was STRICT_NOTEQUAL differ:fullname(5))
    param_nested_struct_field_width,default,CMP_EQUAL,,,equal       (was STRICT_NOTEQUAL differ:fullname(6))
    param_nested_struct_field_width,testflags,CMP_EQUAL,,,equal     (was STRICT_NOTEQUAL differ:fullname(6))
    FuncStructValSimple d/t  file(42)/file(62) -> file(40)/file(60)
    rp32_r5p_alu d/t file(46) -> file(170); bru, mdu file(46) -> file(153); wbu file(46) -> file(169)
    jeras_union d/t fullname(54) -> fullname(121)
    struct_param_func_config d/t fullname(14) -> line(8)
    probe: the 28 conversions and 23 changes the implementer lists (every change a smaller count)

The four grown counts are the walk going further, as claimed. rp32_r5p_alu default with this directory's strictcmp:
pristine `objects 60921 vs 60999 ... type=1 ... objects_differing=46 (walk diverged)`; law `fields: file=17 endcol=1
value=152 objects_differing=170` with 60921 records on both sides; the first three records (#1157 file
`riscv_isa_pkg::isa_t` riscv_isa_i_pkg.sv / riscv_isa_pkg.sv, #1358 value `UINT:00` / `UINT:0`, #1799 value `UINT:05` /
`UINT:5`) are the same on both binaries. The multiset of strict records moves only toward golden on every corpus
mover (evidence/corpus_movers_toward.txt; no record enters that golden lacks):

| row-mode | away (P -> M) | missing (P -> M) | records (P -> M, golden) |
|---|---|---|---|
| FuncStructVal d / t | 578 -> 538 / 1008 -> 968 | 866 -> 826 / 1273 -> 1233 | unchanged |
| FuncStructValSimple d / t | 47 -> 45 / 69 -> 67 | 47 -> 45 / 69 -> 67 | = golden |
| rp32_r5p_alu d | 288 -> 171 | 210 -> 171 | 60999 -> 60921 (60921) |
| rp32_r5p_bru, mdu d | 270 -> 153 | 192 -> 153 | -78 to golden's |
| rp32_r5p_wbu d | 287 -> 170 | 209 -> 170 | -78 to golden's |
| jeras_union d | 154 -> 106 | 118 -> 106 | 19948 -> 19912 (19912) |
| struct_param_func_config d | 37 -> 10 | 175 -> 148 | unchanged |
| struct_param_field_shift, param_nested_struct_field_width | 5 -> 0, 6 -> 0 | 5 -> 0, 6 -> 0 | = golden |

(testflags rows identical in shape.) uhdm-cmp reads 0 lines on all 25 corpus movers of the verified sweep.

**Byte movers** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on hard-link mirrors that leave the 8 fenced
row-mode databases out, `mirrored=2560 fenced_skipped=8`; evidence/byteverify.txt):

| pair | surelog (952) | uhdm2rtlil (1608) | selfcheck |
|---|---|---|---|
| L vs P | 8: FuncStructVal d/t, FuncStructValSimple d/t (LEFTREF), MiniAmiq d/t, SeqDriver d/t (coin) | 16 (the 8 tests above, both modes) | 951/952, 1607/1608 |
| M vs P | 7: the 4 law rows + MiniAmiq d/t, Scoreboard d (coin) | the same 16 | same |
| M vs L | 5: MiniAmiq d/t, SeqDriver d/t, Scoreboard d (coin only) | **0** | same |

The coin rows are the known UVM draws, attributed here, not assumed: no law fires on them (`R11U174_TRACE` prints 0
lines on MiniAmiq and SeqDriver default); three pristine runs of MiniAmiq default give three different databases and
three pristine runs of SeqDriver default give two; ordered = order-blind = 4 dump lines (the UINT/vpiDecompile
`0`/`1366` draw) on MiniAmiq and SeqDriver, and Scoreboard default reads 118 ordered and 0 order-blind lines.
Probe: 59 byte movers P -> L, exactly the implementer's 59 (52 move the normalised uhdm-dump text, 7 are the DEPTH
identity moves r10buvm8 v4order8 vfwdts8 vxpkg8, r10uvm123 g123_c_otherpkg, r10v180 v180_a_share v180_e_ret
v180_i_inst whose dump text is unchanged); L -> M: 0 probe byte movers (evidence/probe_movers.txt).

**Downstream.** P, L and M downstream.csv are identical; 805 non-fenced slang databases, 8 move (jeras_union,
param_nested_struct_field_width, rp32_r5p_alu/bru/mdu/wbu, struct_param_field_shift, struct_param_func_config) and
their `.il`, `_nohier.il` and `_synth.v` are byte-identical to pristine's. Fresh rows (M):
`struct_param_field_shift,IDENTICAL,OK,OK,1,1,,` `param_nested_struct_field_width,IDENTICAL,OK,OK,70,70,,`
`struct_param_func_config,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `rp32_r5p_alu,IDENTICAL,OK,OK,1332,1332,,`
`rp32_r5p_bru,IDENTICAL,OK,OK,174,174,,` `rp32_r5p_mdu,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`rp32_r5p_wbu,IDENTICAL,OK,OK,320,320,,` `jeras_union,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.

**The implementer's grid** (48 cases, evidence/grid_implementer_cases_3bins.txt): 30 go STRICT_NOTEQUAL ->
STRICT_EQUAL, u05 u21 equal on both, l15 u12 u14 stay STRICT_NOTEQUAL, 13 stage 1 on both — as reported. But
**ub/u15 is a break** the implementer filed under "stage 1 on both, same uhdm-cmp text" (section 2).

**Controls** (evidence/controls_bytes.txt): `R11U174_OFF=1` on the verified binary against pristine, same output path:
tests/probe 4087/4087 SAME; the 5123 `dut.sv` cases of tools/probe passes 118-173 (r11u118repro ... r11u173verify,
r11u172rp, r11v1xx; fenced names excluded) 5103 SAME + 20 NODB (no database from either binary). Pristine vs the
verified binary with every law on moves 58 of those 5123: the implementer's 48 (r11u169 ml 17, r11v169 ml 24, r11u172
D 7: 18 go STRICT_EQUAL, d02 stays STRICT_EQUAL, 3 keep STRICT_NOTEQUAL with fewer objects (col 23 -> 18 twice,
fullname 6 -> 1), 26 stage 1 with the same uhdm-cmp text and no golden-agreeing dump line lost) and ten the implementer
did not list: r11u146 fa/f6 and r11u153 fa/g03 (DEPTH, STRICT_EQUAL on both), r11v140 tdc/t07 (DEPTH, stage 1, same
text), r11u159 dd/x01 (LEFTREF, stage 1, same text), and six r11u151struct D2 cases (ASMSPAN): **d01, d04, d05, d08 go
STRICT_NOTEQUAL endcol -> STRICT_EQUAL**, d03 d07 stage 1 with the same text. The implementer's law binary and the
verified binary are byte-identical on all 5123.

## 2. The break: a member read straight off a package parameter

§ elabStructMemberOpFoldUnlocated174 follows the member's base parameter to a user function call and unlocates the
elaborated fold. When the base IS the package parameter (`p::D.A / 2`, or `D.A` through `import p::*` / `import
p::D`), golden keeps the fold located: Surelog elaborates the package before it compiles the module, so the member is
reducible at compile time and the fold carries its span, exactly as pristine wrote it. Only a MODULE parameter (or a
compilation-unit parameter) whose value comes from the function is unknown at compile time.

| case | source | golden | pristine | r11u174 | verified |
|---|---|---|---|---|---|
| mo/b01 | `localparam int X = p::D.A / 2;` | INT:32 at 19:22-19:32 | located | **unlocated** | located |
| mo/b12 | `import p::*; X = D.A + D.B; Y = X * 2;` | both located | located | **both unlocated** | located |
| mo/b16 | `X = int'(p::D.A) / 2; Y = -p::D.C;` | both located | located | **both unlocated** | located |
| mo/b17 | `import p::*; X = D.C * 3;` | located | located | **unlocated** | located |
| r11u174repro ub/u15 | `X = p::D.A / p::D.B;` | INT:12 at 19:22-19:37 | located | **unlocated** | located |
| mo/b19 | `import p::D; X = D.A / Cfg.B; Y = D.A / D.B + 1; Z = X + Y;` | X unlocated, Y located, Z unlocated | all located | all unlocated (Y wrong) | = golden |
| mo/b18 | `$unit` `localparam p::cfg_t G = p::mk(40, 8); X = G.A / G.B` | unlocated | located | unlocated | unlocated (control: the refinement is package-only) |
| mo/b13 | `X = Cfg.A + p::D.B; Y = p::D.A / Cfg.B` | both unlocated | located | unlocated | unlocated |
| mo/b14 b15 | a body / header `localparam cfg_t L = p::D; X = L.A / ...` | unlocated | located | unlocated | unlocated (STRICT_EQUAL) |

All of these are legal SV where pristine was right (b01, b12, b16, b17, u15, and Y of b19). They are stage-1 cases
for an unrelated face (the `p::D.A` hier_path naming, or the import-only module's param_assign typespec), so the probe
sweep cannot see them; the judge text is unchanged by either binary, and the break is read field by field from the
elaborated `param_assign` right-hand sides of uhdm-dump (drivers/pacmp.sh: golden / pristine / law lines,
`lost_golden_lines` = the golden-agreeing lines pristine had and the binary lost).

**§ mopPkgBaseReduces174v** (`R11V174_MOPPKG_OFF`; ParamEmit.cpp emitParameters, inside § elabStructMemberOpFoldUnlocated174's
member-access branch): a member whose base parameter is declared in a package is a reducible leaf (`0`), so the fold
stays located unless another operand is unknown at compile time; a module parameter chained to the package parameter
is followed as before. `R11U174_OFF` drops it with the rest (it reads `r11u174On`); `R11U174_TRACE` prints `MOPUNLOC
pkg base reduces`. Its switch alone gives back the r11u174 bytes on every one of the 140 cases of the switch matrix.

## 3. The adversarial grid (40 cases, cases/, each names its law on its first line)

evidence/grid_verifier_cases.tsv: strict verdict (objects) for pristine / r11u174 / verified, the elaborated
param_assign lines away from golden, the golden lines lost, and whether the uhdm-cmp text moved.

| grid | law | cases | reading |
|---|---|---|---|
| mo | § elabStructMemberOpFoldUnlocated174 | b02 (`<<`, `%`, `==`), b03 (`~`, `&&`, `**`), b04 (generate-block localparam), b05 (header localparam + a range use), b06 (two instances, one overridden by a package parameter), b07 (module-held call default), b08 (module-local function), b09 (interface), b10 (8-bit sized, parenthesised, chained), b11 (sibling `C2 = Cfg`), b13 (mixed operands), b14 b15 (localparam chain), b20 (pattern override) | every one moves only toward golden: STRICT_EQUAL b05 b11 b14 b15; b04 col(11) -> col(2); b06 fullname(15) -> file(1) (the overridden instance abstains, section 5 R3); the stage-1 cases lose no golden line and b02 b03 b10's judge text changes only by dropping the location golden does not print |
| mo | § mopPkgBaseReduces174v | b01 b12 b16 b17 b18 b19 | section 2 |
| lr | § elabParamLeftoverRefUnnamed174 | c01 (generate loop passing the parent's parameter), c02 (three parameters on one struct), c03 (import copy + an import-only module), c04 (interface, two instances), c05 (localparam chain), c06 (procedural and port use), c07 (a call on a member), c08 (unpacked struct: no firing), c09 (nested struct + enum members), c10 (header call on a sibling), c11 (pattern override), c12 (always_comb read) | STRICT_EQUAL c02 c05 c06 c12; the rest stage 1 on both with the same judge text and no golden line lost; downstream verdicts unchanged (c01 EQUIVALENT, c12 IDENTICAL on both binaries) |
| as | § asmRefQualWholeSpanElab174 | c01 (`p::` newline `D`), c02 (a macro plus a comment), c03 (generate-loop override `.Cfg(p::D)`: golden spans the default site 18:39-43 in each instance, as the law writes), c04 (`import p::D`), c05 (`((p::D))`) | STRICT_EQUAL c01 c02 c05; c03 c04 stage 1, same text |
| dp | § pkgFnCastTopListing172 | d01 (typedef of a typedef, enum cast, task cast), d02 (struct cast, a cast in a function of another package), d03 (a class method in the package: no firing) | fires; no verdict or dump-text change (identity moves) |

Downstream verdict of ten of them (mo b01 b02 b05 b12 b17 b19, lr c01 c12, as c03, dp d01) with pristine and the
verified binary: unchanged, and the slang lane's `_nohier.il` byte-identical (0 lines) on all eight that write one.
(dp/d01 reads STATUS_DIFF on both binaries: the slang lane synthesizes no gates for package-function casts, a
pre-existing downstream face outside this pass.)

## 4. Gates of the verified patch (binary law2, sweep M)

| gate | result |
|---|---|
| (1) build | pristine `5f356bac…` = main tree; verified `9cf82ac0…` |
| (2) probe | regressions=0 conversions=28 changes=23; EQUAL 2783 STRICT_NOTEQUAL 1304 (csv identical to L's) |
| (3) surelog / uhdm2rtlil | regressions=0; conversions 0 / 4; changes 2 / 12; scoreboards 480/3 + 474/3 and 803/1 both modes |
| (4) downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, not excused 0; csv identical to pristine's |
| (5) uhdm-cmp | 0 lines on all 25 corpus movers |
| (6) byteverify | M vs L: 0 uhdm2rtlil movers, 5 surelog coin rows; M vs P as L vs P plus the coin draw |
| canaries | ok=52 changed=0, ok=16 changed=0; ctcan2 PASS (ok=58, ok=2) |
| switches | evidence/switch_matrix.txt (140 cases: the implementer's 48, r11u172rp's D/F/S/V 52, these 40): R11U174_OFF = pristine bytes on all 140; R11V174_MOPPKG_OFF = r11u174 bytes on all 140; every other switch moves only cases its law fires on |
| census | drivers/census.sh with the verified binary through the harness, fence-filtered (`fenced mentions: 0`): `MOPUNLOC pkg base reduces` fires on no corpus row-mode and no probe case (hence 0 movers M vs L); `MOPUNLOC` fires on param_nested_struct_field_width d/t and 2 probe cases, `MOPUNLOC abstain` on 11 surelog, 4 uhdm2rtlil and 5 probe entries; the other laws fire as the implementer's census reads |
| law index | `python3 scripts/law_index.py` regenerated tests/LAWS.md (`law index current`) |

## 5. Residues (ranked, this ground) and sister-ground faces

R1. **FuncStructValSimple d/t file(40)/file(60)** — the package-listing leftovers of the call (the implementer's
residue 1): `INT:2` located at the call where golden leaves it unlocated, and a whole-formal leftover whose reference
golden names by the function's own package. Confirmed from the strict records; not worked here.

R2. **FuncStructVal d/t endcol(95)** — pass 169's residue 3; 40 away records leave per mode, the head is unchanged.

R3. **An overridden struct parameter's member fold** (mo/b06 `mid #(.Cfg(p::D)) b()`: golden `work@top.b.X` INT:12
unlocated, ours 18:64-18:77, `STRICT_NOTEQUAL file(1)`): § elabStructMemberOpFoldUnlocated174 abstains on any overridden
link. Reading an override actual that is a package parameter (or a call) as function-built would close it; needs its
own grid (a pattern override stays located in golden: mo/b20).

R4. **ub/u12 and mo/b07** — a module-held call default: golden locates the leftover at the module's own call, ours at
the package's (the stamp shares the first minted leftover); r11u174's residue 4.

R5. **A second function-built parameter in another package** (`p2::D2 = mk2(...)` next to `p::D = mk(...)`, the first
cut of this grid) is stage 1 on every binary (`constant 25:32-34` under the call): the minted leftovers of the second
function are shared with the first's; not this pass's regression, not worked.

R6. The implementer's residues 3, 5, 6 (UVM class-scope casts where DEPTH never fires, lr/l15's package-to-package
read, the pass-169 carried list) stand as reported.

Sister ground: S1 struct_param_func_config d/t `line(8)` (the typedef relocated to the `build` formal's type token,
§ tfArgTypedefLastWriter146 in UhdmExporter.cpp) and S2 rp32/jeras_union (§ tdMoveCarriesFile172 and
§ boundLitWrittenDigits172 in TypeEmit.cpp) are the implementer's, confirmed by the records above.

## 5b. Composition with pass 171 (the main tree moved to `72fd30617` during this verification)

Pass 171 landed the sister ground (r11u172's TypeEmit half included). The verified src patch applies on `72fd30617`
with `git apply --3way` cleanly (disjoint files). Built here: `72fd30617` pristine `fdef3ad724d1655e4f9aa3b8a169655d`
(= the main tree's build/slang-uhdm) and `72fd30617` + the verified patch `0dcb35cdc35ffb0d1f10d431bf11e5fc`. Gate sweep
of the latter against `72fd30617`'s committed baselines (evidence/newhead_composition.txt; all 3273 slang lines name it):

| stage | result at NEWHEAD |
|---|---|
| probe | regressions=0 **conversions=28** changes=23 (the same 51 cases as at the base); EQUAL 2796 STRICT_NOTEQUAL 1291 |
| surelog | regressions=0 conversions=0 changes=2 (FuncStructValSimple d/t file(42)/(62) -> file(40)/(60)) |
| uhdm2rtlil | regressions=0 **conversions=12** changes=4 |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, not excused 0; csv identical to the committed baseline |

**The rp32 rows convert at NEWHEAD** (item (1) of the brief, § pkgFnCastTopListing172 on top of pass 171's
§ tdMoveCarriesFile172 + § boundLitWrittenDigits172):

    rp32_r5p_alu,default   STRICT_NOTEQUAL differ:type(1) -> CMP_EQUAL   (both modes; bru, mdu, wbu the same)
    struct_param_field_shift, param_nested_struct_field_width: STRICT_NOTEQUAL fullname(5)/(6) -> CMP_EQUAL (both modes)

rp32_r5p_alu default at NEWHEAD: pristine's only face is the N0025 divergence (`#15963 type  A: constant INT:31
riscv_isa_i_pkg.sv 144:27-144:29 / B: operation 144:27-144:31`, `objects 60921 vs 60999 ... objects_differing=1 (walk
diverged)`); with the patch `STRICT_EQUAL 60921 objects` (record multiset away 118 -> 1: the one remaining line is the named
typedef root `riscv_isa_pkg::isa_t` reached through a reference, riscv_isa_i_pkg.sv 417:34-39 in golden against its
declaration riscv_isa_pkg.sv 148:9-151:2, a span the comparator's canonical rule excuses because golden gives that
typedef more than one span). jeras_union d/t fullname(36) -> fullname(75) is the walk
completing (pristine `objects 19912 vs 19948 ... (walk diverged)`, patched 19912 = golden's; first records `#168
fullname` and `#176 file` identical on both; records away 108 -> 60, missing 72 -> 60): its remaining faces are the
range constants without a file (r11u172 R5, sister ground). struct_param_func_config fullname(14) -> line(8) as at the
base (S1).

## 6. Ops

* The fence: every driver sources drivers/env.sh (the four names read from RESUME.md, never spelled) and refuses a
  fenced path; the census runs the corpora with the whole-name exclusion filter; byteverify ran on mirrors that leave
  the 8 fenced row-mode databases out; no fenced source, database or head was read; nothing in this directory names
  one. Only the gate sweeps dispatched every row.
* No process I did not start was touched; the sister's, r11u175's and the implementer's worktrees were not written
  (the implementer's patch and README were read).
* The main tree moved to `72fd30617` (pass 171) during this verification; its results/ are that landing's, so the
  canaries were run against the base's results/ (the worktree's). Run against the main tree's newer baselines they
  read `changed=11` on every binary, pristine included (the rows pass 171 re-baselined), which is not a mover.
* A first build of the new-head worktree was killed by the out-of-memory killer while two builds and a sweep shared
  15 GB; it was rebuilt alone.

## Files

drivers/: env.sh (tool paths, `$FENCED`), grid.sh (one case: golden + ours + uhdm-cmp + strictcmp), pa.py + pacmp.sh
(elaborated param_assign right-hand sides of golden / pristine / binary), dmcmp.sh (uhdm-dump line multisets: away,
missing, golden lines lost), swmat.sh (switch matrix), cmp2.sh (bytes of two binaries at one output path), toward.sh
(strict record multisets of a corpus row), ds.sh (one case through the downstream harness), sweep.sh (a gate sweep),
pdump.sh (normalised dump comparison of a probe database), census.sh + tracewrap.sh (the firing census, copies of
r11u174's). cases/: 40 cases. evidence/: the files named above.
