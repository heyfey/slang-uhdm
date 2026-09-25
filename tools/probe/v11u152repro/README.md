# v11u152: adversarial verification of r11u152 (the module/type ground on the strict axis)

Base `d10675dd` (branch matrix-1.87). Implementer's patch `r11u152` (14 laws). Verdict: **ACCEPT-WITH-FIX**.
Every headline number of the implementer reproduces bit for bit on binaries built here. One break was found
by fresh cases: § classVarInitSpan152's elaborated half widened a module-scope class handle to its initializer
where golden keeps the name span. It is legal SV, and pristine was right on 3 strict-equal cases and 5
downstream-IDENTICAL cases. It is refined under one new switch, § classVarInitNewDecl152v
(`R11V152_CLSVARNEW_OFF`). No gate row, probe case or downstream row moves between the implementer's binary
and the refined one, except the known UVM order coin.

The slang-fenced tests are written `FENCED=` here. Every driver that reads corpus databases refuses to run
without `$FENCED` and skips those names (`drivers/corpusdist.sh`). No fenced test was run on its own, read or
decoded. The full sweeps run them as part of the gate, as every pass does.

## 1. Binaries (frozen `chmod 555` before any measurement; every `cmds.txt` audited by path)

| binary | md5 | what |
|---|---|---|
| `/tmp/v11u152_bin/pris.bin` | `0a647f63db9a3a6b6811c14d2c10f4e3` | own worktree at d10675dd, system-deps config, `-j 2` (equals the brief's pristine) |
| `/tmp/v11u152_bin/law.bin` | `0a5eed3a32dc0aeefe4abf086c5de435` | d10675dd + `r11u152.patch` (byte-identical to the implementer's final `law2.bin`) |
| `/tmp/v11u152_bin/fix1.bin` | `3d399d966a50b588da3306337a004f64` | d10675dd + the verified patch (this README's refinement) |
| `/tmp/v11u152_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator |

Sweeps (`drivers/sweep.sh`, `tests/sweep.sh --jobs 3`): `/tmp/v11u152_swP` (pristine), `/tmp/v11u152_swL`
(law), `/tmp/v11u152_swF` (fix). The three workdir names have the same length. Every `cmds.txt` names its
own binary. Surelog: 1531 of 1581 in each sweep; the other 50 have no slang line (Surelog-fail and
untranslatable rows). uhdm2rtlil: 1742 of 1742. No `cmds.txt` names the main-tree binary.

## 2. The implementer's headline numbers, reproduced (`evidence/sweeps/sweep_{pristine,law,fix1}.log`)

| gate | pristine | law (implementer's binary) | fix (this patch) | claimed |
|---|---|---|---|---|
| probe | EQUAL 2390 / STRICT_NOTEQUAL 1697; 0/0/0 | EQUAL 2436 / 1651; regressions 0, conversions 46, changes 65 | same csv as law, byte-identical probe databases (0 of 4087 move) | same |
| surelog | CMP_EQUAL 406 + 405 (judge-equal 480 + 474); 0/0/0 | 415 + 414; regressions 0, conversions 18, changes 8 | csv equal to law (only the LowMem detail-text workdir path) | same |
| uhdm2rtlil | 714 + 714; 0/0/0 | 721 + 721; regressions 0, conversions 14, changes 26 | csv identical to law | same |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 | equal to pristine on all 871 rows in every column | identical to law | same |
| canaries | surelog ok=52, u2r ok=16; ctcan2 PASS, PASS | surelog ok=46 changed=6 (Earlgrey_0_1, ClassParamAsParam, ClassTypeParam d/t), u2r ok=16; PASS, PASS | same as law | same |
| byte movers vs pristine | | surelog 32 / 960, uhdm2rtlil 40 / 1608 (SELFCHECK 959/960, 1607/1608; path sets identical) | vs law: surelog 6 (UVM coin), uhdm2rtlil 0 | 32 / 40 |

The fresh rows of the seven converted uhdm2rtlil tests read downstream IDENTICAL with `differs` empty:
`type_param_packed_dim,IDENTICAL,OK,OK,9,9,,` and six `...,IDENTICAL,NO_GATES,NO_GATES,0,0,,` rows
(FileLevelUnionWithMultirange, LocalParamInNestedForLoops, packed_array_struct_port_sel,
struct_member_cfg_width, StructArrayParameterInitializedByPatternPassedAsPort, VarPassedTo2Submodules).

- **Law index.** The pristine sweep exits 1 only on `law index STALE`: a tree checked out at a commit always
  reads that commit as missing from the committed `tests/LAWS.md`, so this comes from the environment. The law
  sweep reads `law index current` and exits 0, because the implementer's patch carries the regenerated index.
- **Movers.** The surelog mover set equals the implementer's except for one UVM coin swap: MiniAmiq default
  here, SeqDriver default there. The uhdm2rtlil set is identical.
- **Changes.** All 99 CHANGE lines (65 probe, 8 surelog, 26 uhdm2rtlil) lower the object count. None grows.
- **Attribution.** The 111 probe cases the law moved were re-run with the law binary and one switch each
  (`evidence/sweeps/probe_attribution.txt`). The tally equals the implementer's: TPELEMPAT 76, GENCASE 15,
  CLSVARINIT 7, CLSPANOFILE 3, CGINITEND 2, C3 2, TPOVRSTRUCT 2, DLYREAL 2, PKGLEAFLOC 1, TPELEMPAT+TPOVRSTRUCT 1.
  `R11U152_OFF` returns all 111 to their pristine verdict.
- **Probe byte-only movers.** Record-level (`uhdm-strictcmp --no-canon`, pristine against law) and dump-level
  instruments find 122 movers: the 111 plus 11 byte-only. The implementer lists 13: the two extra (r11v32
  h03_enum_alwaysff, r11v95 x4_proggencase) move in bytes neither instrument reads. Against golden
  (`--no-canon` count), every one of the 13 stays equal or gets closer. The two CLSPANOFILE movers (r10sd1 b9_inline,
  r10uvm55 a1) take golden's empty file on the specialization param_assign.
- **Order-blind dump distance.** It reads 39 TPELEMPAT probe movers as "away" (`evidence/sweeps/probe_dumpdist_away_tpelempat.txt`).
  That is a dump artefact of the new per-use copy: the dump prints a shared object's subtree differently from a
  copy. The raw walk (`--no-canon`) and the canonical walk both read every one as equal or closer, e.g. e01_base
  3 -> 2 raw and 2 -> 1 canonical.
- **Corpus movers against golden** (`evidence/sweeps/corpus_movers_dumpdist_law_vs_pris.txt`, 72 row-modes).
  62 are closer in the order-blind dump distance and 6 are equal: DelayAssign d/t, which converts on the strict
  axis, and the UVM coin rows. 4 read "away": SimpleUVM d and SeqDriver t by the 4 coin lines, and
  type_param_override_elem_sel d/t by the TPELEMPAT copy artefact. That row's raw walk goes 3 -> 2 objects in
  both modes.
- **Implementer's grid.** All 102 cases re-run with my binaries (`evidence/grid/grid_law_r11u152cases.txt`)
  agree with the implementer's `gridall.txt` case by case: verdicts, `R11U152_OFF` bytes and own-switch bytes.
  Pristine EQUAL is **14**, not the 15 of the implementer's final report; its README table sums to 14. Law
  EQUAL is 75.
- **Driver defaults.** `gridall.sh`, `attrib.sh`, `attrib_probe.sh` and `uvmmovers.sh` of r11u152repro
  defaulted to the superseded `law.bin`. They now default to `law2.bin`. The evidence reproduces with the final
  binary either way.

## 3. The break and its refinement

**Face.** § classVarInitSpan152 (ModuleEmit.cpp, the elaborated module-scope variable) spans every
initialised module-scope `class_var` from its name through the initializer. Golden does this only when:

- the class type is written as a specialization (`C#(..)`) or a scoped name, or
- the DECLARATION holds a `new` initializer.

A bare class name with any other initializer keeps the name span.

| case (`cases/KW`, `KX`, `KV`, `KY`) | source | golden class_var | law | fix |
|---|---|---|---|---|
| w07_copy_only | `C c1; C c2 = c1;` | c2 7:5-7:7 | 7:5-7:12 (STRICT_EQUAL -> endcol) | 7:5-7:7 (STRICT_EQUAL) |
| w04_static_call | `C c1 = C::make();` | 10:5-10:7 | 10:5-10:19 (STRICT_EQUAL -> endcol) | STRICT_EQUAL |
| x07_call_copy | `C c1 = C::make(); C c2 = c1;` | name spans | both widened (STRICT_EQUAL -> endcol) | STRICT_EQUAL |
| v02_copy_init | `C c1 = new; C c2 = c1;` | c1 through `new`, c2 name | c2 widened | STRICT_EQUAL (pristine endcol) |
| v01_null_init, x02_null_null | `C c1 = null;` / `C c1 = null, c2 = null;` | name spans | widened (stage-1 cases) | name spans |
| x03 / x04 | `C c1 = new; C c2 = null;` in either order | c1 through, c2 name | both through | golden |
| y08_spec_typedef_null | `typedef C#(int) ct; ct c1 = null;` | name span | widened | name span |
| controls | `C c1 = C::make(), c2 = new;` (x01), `C c1 = new, c2 = null;` (w05), `C c0, c1 = new;` (x08), `C#(longint) c1 = null;` (w01), `C#(longint) b = a;` (w02), `pk::C c1 = null;` (x05) | through (x01 both, w05 c2 too), w01/w02 through | through | unchanged from law |

**Downstream.** The plugin reads the class_var span into src attributes. Under the law, v01, w04, w07, x02 and x07
leave IDENTICAL for EQUIVALENT (`nohier` differs). Under the fix all five read IDENTICAL again
(`evidence/downstream/cases_{pris,law,fix1}.txt`).

**Law § classVarInitNewDecl152v (verifier refinement of § classVarInitSpan152).** A handle whose class type is
written as a bare identifier keeps its name span unless one declarator of its data declaration is initialised
by `new` (`NewClassExpression`). A specialization or a scoped type spans through any initializer, as the law
had it.

- **Site:** ModuleEmit.cpp at the § classVarInitSpan152 site (`newDecl152v`).
- **Switch:** `R11V152_CLSVARNEW_OFF` restores the implementer's bytes on every case (checked on 39 class
  cases: the 33 of KV, KW, KX and KY y08 plus the implementer's 6 CV cases). `R11U152_OFF` still restores pristine bytes on every case: 112
  here plus the implementer's 102.
- **Decode:** from the golden grid KW/KX (17 cases). Surelog's parse selects the class-typed data-declaration
  production (`Class_new` in ElaborationStep.cpp's variable-assignment branch) only when a `new` or a
  parameterised or scoped class type forces it. The name-only span is the other production's identifier node.
- **Prediction before the fix sweep:** no gate mover. The seven probe cases CLSVARINIT moves all initialise
  with `new`/`new()` at module scope. t40d's `g_null = null` is package scope. The corpus class rows use
  `C#(..) = new`. Measured: probe 0 of 4087 databases move (byte compare, same tree), uhdm2rtlil 0 of 1608,
  surelog 6 of 960. The 6 are the UVM coin family: MiniAmiq d/t, SimpleUVM d/t, SeqDriver t, Scoreboard d, each
  0 or 4 order-blind lines, all `UINT`/`vpiDecompile` (`evidence/sweeps/uvm_coin_fix1_vs_law.txt`).

## 4. The other laws under fresh instances (`cases/`, 112 cases, `evidence/grid/`, `evidence/downstream/`)

Each case was run through uhdm-cmp and uhdm-strictcmp against the pinned Surelog's golden, an order-blind dump
distance to golden (`drivers/dumpdist.py`) and the downstream verdict (`drivers/dscase.py`). Pristine EQUAL
is 10 and fix EQUAL 44. No case leaves STRICT_EQUAL under the fix, and none leaves downstream IDENTICAL under
the fix (pristine 76 IDENTICAL, law 92, fix 101 of 112).

| dir | law | cases | what held |
|---|---|---|---|
| K3 | § portConnParamFoldAtActual152 | 9 | explicit import, two instances convert. A local localparam, a mid-level instance, an implicit `.a_i`, `.*` and a parameter override read stage-1 at pristine and are unmoved |
| KL | § genLpOperandTsNoParent152 | 7 | loop in a case block, in an else block, nested in a child, loop-in-loop: every one closer (l05, l07 convert). A child's top-level loop, an interface loop and a `generate` region are unmoved |
| KT | § tpElemPatAtUser152 | 7 | output port, element override, package-struct element: t02 and t05 convert. A non-local override and a named override are unmoved |
| KS | § tpOvrTypedefStructSpan152 | 10 | two modules in either order, a parent that has its own type parameter `T` and a bare unpacked use all convert (so no stale-scope read). Typedef-only use, net use and interface: closer, stage-1 |
| KG / KY y10 | § genCaseItemUnnamed152 | 7 | in a loop, in a named if, nested case, parameter item expressions, child with two specializations, unnamed multi-label: 5 convert, 2 closer |
| KD / KY y09 | § delayLiteralValueText152 | 7 | `#1.0`, `#10.50`, a timescale, a child, `wire #1.5 w1 = a, w2 = a` all convert. Gate delay and `#(1.5, 2.5)` are stage-1 / rejected at pristine and unmoved |
| KU | § pkgElemMemberPatNoLoc152 | 6 | member of a struct in another package, nested struct, enum element, unpacked struct: all convert. Class struct and an interface user: closer, stage-1 |
| KE | § packedElemAliasTypedef152 | 5 | e05 (alias in another package) converts, e02-e04 closer. See residue 3 for e01 |
| KB | § crossPkgFoldTsNameOnChain152 | 4 | closer or unmoved, all stage-1 at pristine |
| KC / KW w06 | § unsupportedTsInitEnd152 | 5 | two handles, multi-line initializer: convert. In an interface: closer. `= null`: see residue 2 |
| KV / KW / KX / KY | the class laws | 34 | § classSpecNestedAtName152 (double nesting, no initializer, typedef, class member and function local) and § classSpecPaNoFile152 (value parameter, extends, class member, two parameters) all convert or get closer. § classVarInitSpan152: section 3 |
| KP / KY | § pkgLeafPatLocByWriting152 | 11 | explicit import, module typedef, enum leaf, parameter-typed, class property, task `input` argument (y03 converts): unmoved or closer. See residue 1 |

## 5. Residues (decoded here, not landed), ranked

1. **§ pkgLeafPatLocByWriting152, direction-less function argument.** In `function int f(s_t [2:0] v)` (module
   or package, KP p03 and KY y04), golden spans only the name, 6:28-6:31. The law now writes golden's file, line
   and column but ends at the dims (6:37); pristine wrote no location. A task `input` argument spans the dims
   (y03 converts). This is the next face of the same branch in TypeEmit.cpp makeTypespec.
2. **§ unsupportedTsInitEnd152 with `= null`.** For `cg h = null;` (KW w06), golden's unsupported_typespec spans
   only `cg` (7:3-7:5) and there is no elaborated variable. Pristine ended at 7:21 and the law at 7:20: stage-1,
   wrong both ways.
3. **§ packedElemAliasTypedef152, alias of an alias.** In `typedef tx_t ty_t; lp::ty_t [0:0] w` (KE e01), golden's
   element is named `lp::ty_t` with the enum's span 3:4-3:51. The law gets the name right, but spans the
   middle typedef's line (4:4-4:22). Stage-1 at both. The case is downstream DIVERGENT at pristine already
   ("Constant value mismatch") and stays so.
4. **§ portConnParamFoldAtActual152, positional connection** (`sel u(Attr, o)`, K3 k08). Golden keeps a `ref_obj`
   high connection (`work@top.Attr`, 11:9-11:13) whose actual is the parameter's pattern. The law relocates our
   fold to 11:9-11:13, which is golden's high-connection span, and names its ts ref `work@top.u.a_i`. Stage-1
   before and after (the fold against golden's ref_obj). This is the same class as the implementer's C3 c10.
5. **KS s04** (`typedef T [1:0] arr_t; arr_t q;`): downstream STATUS_DIFF at pristine, unchanged.
6. The implementer's residues 1-12 (N0472, the ibex family, ParamTypespec2, NestedStructArray..., gen_scope_typaram,
   ClassTypeParam, CV v02, C3 c07/c10, GenerateUnnamed, StructUnsizedVal, N0078, OneNetModport) stand as
   written. Nothing here contradicts them.

## 6. Drivers

`drivers/case.sh` runs one case: golden with check_probe's arguments, ours with `--single-unit --nobuiltin`,
then uhdm-cmp and uhdm-strictcmp. `drivers/grid.sh` runs pristine, law, `R11U152_OFF` and the own switch
(named by the case's first line) per case. The other drivers:

- `drivers/dumpdist.py`: order-blind dump distance to golden.
- `drivers/corpusdist.sh`: the same distance over corpus movers. It refuses to run without `$FENCED`.
- `drivers/normmd5.sh`: normalised dump hashes.
- `drivers/dscase.py`: the downstream verdict of a case, using the harness's own `one()`.
- `drivers/sweep.sh`: the gate sweep with a frozen binary.
