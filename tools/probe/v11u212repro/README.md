# v11u212: adversarial verification of r11u212 (pass 212, the module/type ground)

Base `b69dc2da` (pass 209). The pass under test: /tmp/r11u212.patch (md5 `0002d89b`), its six laws
§ anonMemberTdLastWriter212, § pkgEnumAliasListingParent212, § queueMemberSpanToDim212, § sizeDimOvrFileAtDim212,
§ signCastSysCallLhsTs212 and § ndaSysCallNetTs212 (tools/probe/r11u212repro/README.md).

**Verdict: CONFIRMED WITH ONE BREAK, fixed here behind its own switch.** Every headline number of the pass reproduces
bit for bit. On fresh cases, § anonMemberTdLastWriter212 moved a strict record that pristine had equal to golden away
from golden on legal SV: a module-scope typedef declared in a header (or a multi-line macro) that two definitions
include. The refinement § anonMemberTdOwnerDef212v (`R11V212_TDOWNER_OFF`, `R11V212_OFF` drops it) restores golden on
all 16 case-views of that family. It fires on no corpus row, probe case or downstream lane and moves no gate database.
No other law broke.

## 1. Reproduction of the pass (fresh worktrees /tmp/wt_v11u212pris and /tmp/wt_v11u212, both at b69dc2da)

| item | implementer | this verification |
|---|---|---|
| pristine build | `e453e0e2` | `e453e0e281c4bc7ad330c68a5eda1295` (byte-identical) |
| law build (r11u212.patch on fresh b69dc2da) | `318e90a3` | `318e90a35b26e2494948a5bfe45418c6` (byte-identical) |
| patch applies on fresh b69dc2da, `law_index.py --check` | yes | yes (17 whitespace warnings: the CRLF case q09 and a trailing-space case) |
| probe | 3407 + 680, reg 0 / conv 4 / chg 2 | the same four conversions and two changes, reg 0 |
| surelog | 927 + 27, reg 0 / conv 0 / chg 10 | the same ten CHANGE lines, reg 0 |
| uhdm2rtlil | 1596 + 10, reg 0 / conv 0 / chg 2 | the same (anon_struct_packed_dim d/t fullname(43) -> (4)) |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, rc 0; verdicts identical to the pristine sweep and to the baseline row for row |
| byte movers | surelog 10, u2r 2, probe 6, downstream lane 1 | surelog 10 (SELFCHECK 959/960), u2r 2 (1607/1608), probe 6 of 4087, downstream 1 of 805 (anon_struct_packed_dim, IDENTICAL) |
| frozen predictor | md5 `25d42148`, 20 lines | re-derived with the fix binary: md5 `25d42148`, identical, fence hits 0 0 0 0; every mover predicted, TypedefEnum d/t predicted and unmoved |
| pass switch | pristine bytes on 4087 probe, 13 of 14 corpus | `R11U212_OFF=1`: 4087 / 4087 probe databases byte-identical to pristine with an identical probe csv; 13 of 14 corpus databases byte-identical, Scoreboard d sorted-dump-identical (the svunit listing coin) |
| away census (chain-keyed) | away 0, toward 161; reversed 161 | away 0 on all 18 movers, toward 161; reversed control 161 |
| UVM distance base -> law | 6539/5084/1994/1462/720 -> 6528/5071/1983/1453/713 | identical in dist and sym |
| determinism | no new coin | three concurrent runs per binary: Earlgrey, SeqDriver, SimpleUVM, BuildUVMPkg one hash per mode; MiniAmiq and Scoreboard d two hashes each with sorted dumps identical per binary (the known coins). The fix binary draws the law binary's hashes. |
| grid | 150 case-views: 78 -> EQUAL, 23 stay, 0 leave, 10 leave stage 1 | row for row identical (evidence/grid/grid_law_vs_fix_all.tsv, r212/ rows) |
| canaries | surelog ok 45 / changed 7, u2r 16 / 0, ctcan2 PASS | the same, with the csvs judged against b69dc2da's results/ |

Every one of the 3273 `slang:` lines of each corpus sweep names that sweep's frozen binary (/tmp/v11u212_bin/pristine.bin,
law.bin, fix1.bin). The downstream stage records no command line, so the binary was exported explicitly per sweep.
Rggen #23164's Surelog-defect ruling is confirmed at the source: `NetlistElaboration.h` declares
`using TypespecCache = std::map<NodeId, UHDM::typespec*>;`, and `elab_ports_nets_` looks the cache up by
`sig->getTypeSpecId()` alone, across FileContents.

## 2. Fresh cases (cases/, 74 cases x 2 views = 148 case-views; drivers/j.sh, drivers/k.sh)

Each case is judged in both views against the v1.87 pin by uhdm-cmp and uhdm-strictcmp field by field (pristine, law,
fix), and by the downstream verdict (drivers/ds.py, the gate's own `one()`, fresh GOLDEN_CACHE).

| family (law under test) | cases | pristine -> law (case-views) |
|---|---|---|
| A (§ anonMemberTdLastWriter212): other-module listings in both name orders (a01-a03), byte order `Zeta`/`alpha` (a04), `mod9`/`mod10` (a05), a header included late in the body (a06), a $unit class property (a07), a static task local (a08), two anonymous structs on one line (a09), a union typedef (a10), an interface variable (a11), enum members in two modules (a12), package and module typedefs mixed (a13), a child in a second file (a14), a localparam (a15), nets (a16) | 16 | fullname -> **EQUAL 21**; fullname -> fullname 5 (a06 both views, a07 both, a13_el); stage 1 both 6 (a08, a15, a16) |
| B (§ pkgEnumAliasListingParent212): another package's enum (b01), alias of alias (b02), struct member (b03), class property (b04), qualified use (b05), two packages (b06), a port assigned a constant (b07), a package parameter (b08) | 8 | fullname -> **EQUAL 10**; EQUAL -> EQUAL 4 (b05, b07); fullname -> line 2 (b02) |
| C (§ queueMemberSpanToDim212): queue of fixed arrays and a packed-element queue (c01), a package-typedef element (c02), comments in the member (c03), a macro dimension (c04), a macro-argument name (c05), a queue of queues (c06), an anonymous class-property struct (c07) | 7 | endcol -> **EQUAL 10**; endcol -> fullname 4 (c02, c07: pre-existing member-scope names) |
| D (§ sizeDimOvrFileAtDim212): an interface-array instance (d01), a macro dimension (d02), a three-file chain (d03), defparam (d04), a hex override with two instances (d05) | 5 | file -> **EQUAL 2** (d02); stage 1 both 8 (d01, d03, d04, d05; the stage-1 output of d03 and d05 unchanged) |
| E (§ signCastSysCallLhsTs212 / § ndaSysCallNetTs212): signed output port, struct variable, implicit net, concatenation, parameterized child, scalar wire, non-ANSI port (e01-e06, e17); $clog2, $bits, $high, two declarators, scalar, typedef net, tri/wand, child in a generate loop, generate-block net, $size/$left (e07-e16) | 17 | stage 1 -> **EQUAL 18**; EQUAL -> EQUAL 4 (e07, e08: slang folds the call); stage 1 -> endcol 2 (e14: the definition-net residue); stage 1 both 10 (e05, e09, e12, e15, e16) |
| G (mixed): a class-scoped enum alias (g01), an alias typing a package function (g02), an alias written by a macro (g03), two aliases through imports (g04), queues in an interface and a program (g05, g06), casts onto int/bit and a type-parameter variable (g07, g08), a bind (g09), a macro cast and a two-line cast (g10), a parameterized nda (g11), a struct net (g12), $low/$right (g13) | 13 | stage 1 -> **EQUAL 6**, fullname -> **EQUAL 2** (g03); EQUAL -> EQUAL 2 (g04); stage 1 -> strict record 3 (g08, g09 parse: fullname; g11 parse: type); stage 1 both 13 |
| F (the break, section 3) | 8 | see section 3 |

**Totals (A-E, G; 132 case-views): 69 convert to EQUAL, 10 EQUAL stay EQUAL, none leaves EQUAL; 29 stage-1 cells leave
stage 1 (24 to EQUAL); no strict count grows.** Every non-converting mover is a strict subset of its pristine records
(B b02 `fullname=3 line endline endcol` -> `line endline endcol`; C c02 8 -> 4 objects; C c07 3 -> 2; A a13_el 7 -> 1). The
stage-1 movers were diffed line by line: d03, d05, a08, a15, a16, e12, g02, g05, g06 are unchanged, and the others
only add the new stamp or parent to an object that already differs (e05 / g11_el: the stamp binds the definition's
unfolded `W-1` range where golden binds the instance's folded one; e09, e16, g13: section 4 item 3; g01: the alias
parented at its package beside golden's own `unsupported_typespec` there; g12: a struct net's structural record).
Downstream: all 74 cases read the same verdict on pristine, law and fix (73 IDENTICAL, g12 EQUIVALENT on all three).
Every switch was checked on every case-view: `R11U212_OFF` restores pristine bytes on 148 / 148, and `R11V212_OFF`
restores the law's bytes on 148 / 148 (evidence/grid/). The second-root files of A/a14 and D/d01-d05 were given
their law line after the first grid. The six cases were re-judged on the edited text with fresh goldens and a fresh
downstream cache: the same verdicts, the same stage-1 output, and all 18 downstream runs IDENTICAL
(evidence/grid/grid_AD_redo.tsv, evidence/downstream/ds_AD_redo.txt).

## 3. The break and the refinement

**Break (§ anonMemberTdLastWriter212, UhdmExporter.cpp `typedefParentModel134`).** The law keys the last anonymous
member by the typedef's kind, name, file, line and column, then gives that one member to every typedef object of the
key. When a module-scope typedef is declared in a header that two definitions include (or by a multi-line macro that
both invoke), both definitions' typedefs share the key. The law then re-parents every definition's typedef at the
single global last member. Golden is per definition: each definition's anonymous member re-parents only its own
typedef, and a definition with no anonymous member keeps its listing. In the elaborated view the strict walk sees it
(evidence/grid/F_away_records.txt):

| case-view | record | golden | pristine | law | fix |
|---|---|---|---|---|---|
| F/f01_el (aa plain variable, zz anonymous) | #149 | `work@aa.in_t.b` | `work@aa.in_t.b` | `mz.in_t.b` | `work@aa.in_t.b` |
| F/f03_el (interface ii, module dut) | #215 | `work@ii.in_t.b` | `work@ii.in_t.b` | `mz.in_t.b` | `work@ii.in_t.b` |
| F/f04_el (aa anonymous, zz plain) | #220 | `work@zz.in_t.b` | `work@zz.in_t.b` | `ma.in_t.b` | `work@zz.in_t.b` |
| F/f06_el (top zz plain, child aa anonymous) | #239 | `work@zz.in_t.b` | `work@zz.in_t.b` | `ma.in_t.b` | `work@zz.in_t.b` |
| F/f08_el (the macro form) | #147 | `work@aa.in_t.b` | `work@aa.in_t.b` | `mz.in_t.b` | `work@aa.in_t.b` |
| F/f02_el (both anonymous) | #169 | `ma.in_t.b` | `work@aa.in_t.b` | `mz.in_t.b` | `ma.in_t.b` |

In five case-views, a record pristine had equal to golden moves away. In the parse view the strict walk
canonicalises these names inside the typespec subtree and reads EQUAL, but the dump shows the same wrong parent
(evidence/grid/F_typedef_member_names.txt). For example, f01 golden has `mz.in_t.*` once and `work@aa.in_t.*` once,
while the law has `mz.in_t.*` twice. The enum form f05 behaves the same way (golden `ea.e_t` and `ez.e_t`; law `ez.e_t`
twice). The away census in section 1 cannot see this: no corpus row or probe case includes such a header.

**Refinement § anonMemberTdOwnerDef212v (v11u212).** A typedef object whose listing sits under a module, interface or
program (its nearest `module_inst` / `interface_inst` / `program` ancestor, compared by definition name) takes only
its own definition's last anonymous member, or none. A typedef listed under no definition (a $unit typedef: the
design; package and class typedefs are declined by the law already) keeps the global last member, which the law's
cross-module grid measured (A a01-a05, F f07). Switch `R11V212_TDOWNER_OFF`; `R11V212_OFF` drops every v11u212
refinement. Its firings are traced as `anonMemberTdOwnerDef212v` through `R11U212_TRACE`.

| F case | pristine | law | fix |
|---|---|---|---|
| f01-f04, f06, f08 (elaborated) | fullname | fullname (the moved record) | **EQUAL** |
| f01-f04, f06, f08 (parse) | fullname | EQUAL, dump wrong | **EQUAL, dump equal to golden** |
| f05 (enum, both views) | fullname | EQUAL, dump wrong | **EQUAL, dump equal to golden** |
| f07 ($unit control, both views) | fullname | EQUAL | EQUAL, bytes equal to the law's |

Downstream: all eight IDENTICAL on pristine, law and fix. The fix changes bytes on no other case-view of the 282 in
the grid (the implementer's 150 plus families A-E and G). The wide byte control covers 172 earlier case directories
under tools/probe whose files hold an include and an aggregate, or a macro and a typedef (344 case-views; 5 of them
list their roots in `files` and were re-run with them): 0 movers between law and fix, 0 firings of the refinement
(evidence/grid/v11u212_wide_*.txt).

**Gates with the fix binary** (`fix1.bin`, md5 `d5b3d147a50dcbee49413139a0948f31`; sweep /tmp/v11u212_sF):
- **Prediction, frozen before the sweep:** fix vs law movers NONE, since the refinement fires on no corpus row-mode
  or probe case. The firing census over the probe set and both corpora in both modes, `--filter` built from
  `$FENCED`, had fenced hits 0 0 0 0 (evidence/census/).
- **Probe:** 3407 + 680; regressions 0, conversions 4, changes 2 (the law's).
- **surelog:** 927 + 27; regressions 0, conversions 0, changes 10 (the law's ten lines).
- **uhdm2rtlil:** 1596 + 10; regressions 0, conversions 0, changes 2.
- **downstream:** 803 / 66 / 2 / 0, rc 0; verdicts identical to pristine row for row; 0 lane movers vs the law.
- **Bytes vs the law:** probe 0 / 4087; uhdm2rtlil 0 / 1608; surelog 1 / 960. The one surelog mover is Scoreboard
  default: `de42a8e468b9` vs `50f1e9cd5845`, both draws of the law binary itself, 92 ordered lines, sorted dumps
  identical (the known svunit listing coin).
- **Away census vs pristine:** away 0, toward 161 on the same 18 databases; the reversed control reads 161.
- **UVM distance:** the law's figures exactly.
- **Determinism:** the law's hashes. Canaries surelog 45 / 7, u2r 16 / 0, ctcan2 PASS both.
- **`R11U212_OFF=1` on the fix binary:** pristine bytes on the 14 predicted corpus databases (13 byte-identical,
  Scoreboard d the coin, sorted-identical).

## 4. Findings that are not breaks, ranked

1. **Declaration order across an include (A a06).** The law orders one definition's members by line and column. A
   header included after a module variable holds a member on a smaller line. Golden takes the header's member
   (declaration order: `mhdr`); the law takes `mfirst`. Pristine is wrong too (bare), and the strict count is
   unchanged (14 -> 14). A buffer-order sort would close it.
2. **The net-declaration stamp binds the definition net's typespec** (the implementer's own residue, confirmed on
   parameterized widths). In e05 and g11_el the stamp's actual is the definition's `[W-1:0]` with an unfolded
   operation, where golden binds the instance's folded range. These stay stage 1, and downstream is IDENTICAL on all
   three binaries.
3. **§ ndaSysCallNetTs212's range-query branch is ungridded and never matches golden in the fresh cases.** Golden folds
   `$high`, `$size`, `$left`, `$low` and `$right` in a net-declaration initializer to a constant (`UINT:5` at the
   bound, e09). Ours keeps the sys_func_call, and the law adds a `ref_typespec` to it (stage 1 before and after; 14
   more dump lines in the parse view; downstream IDENTICAL). The fold belongs with q08's generate-scope fold
   (ModuleEmit's net-declaration branch has no `sysFold`). Left as landed: it fires nowhere in the gates.
4. **Parse-view cont_assign names of a type-parameterized or bound module (g08, g09).** The parse view prefixes the
   definition's cont_assign objects with an instance path (`work@dut.u`, `work@dut.b`) where golden writes the
   definition (`work@c`, `work@chk`). This was already true at the base behind a stage-1 record; the new stamp's full
   name follows the same prefix (ModuleEmit, the definition prefix of a module emitted from its first instance).
5. **Unmasked pre-existing names** (not this pass's, each a strict subset of pristine): b02's alias of an alias is
   located by golden at the enum's own declaration (ours at the first alias). In c02 and c07, a queue member's
   element typedef and an anonymous class-property struct's members are named through their owners in golden
   (`p::p::pkt_t::data::byte_t`, `p::k::st::s`), where ours is bare. In a13_el the package typedef inside an
   anonymous struct reads `mp.p::pk_t.a` in golden (the implementer's s17_el).
6. **Downstream face g12:** a packed-struct net with a declaration assignment reads EQUIVALENT (nohier) on pristine,
   law and fix. It is not this pass's; report only.

The implementer's own residue list (the sister's `gx` records of anon_struct_packed_dim, InterfArrayBind, Rggen
#23164, BuildUVMPkg #26067, the importing-context family, Earlgrey's ground-A heads, c06's inner cast, q08) stands as
written. Pass 210, which landed on the branch during this verification (a727b8c7d), moved InterfArrayBind d to
fullname(1) and states anon_struct_packed_dim's `gx` records as not attempted. Its csvs are not this base's.

## 5. Process and fence

* **Binaries** were frozen `chmod 555` in /tmp/v11u212_bin before any measurement, and every cmds.txt was audited
  by path. Builds used `-j 2`, and no source was edited while a unit compiled.
* **Scratch** is `/tmp/v11u212_*` only. Sweeps: sP (pristine), sQ (law), sF (fix), same-length names. Also pL (law
  probe from the pristine worktree for byte comparison), pO (the pass switch), sO (the corpus pass switch), the
  census cen, g (case goldens), dsw_* / dsg (downstream), det*, wide.
* **Fence:** every driver that reads corpus sources or databases takes the four names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh and fails closed (env.sh, case.sh, census.sh, wide.sh, ds.py, awayrows.py,
  det.sh, uvmdist.sh). The census corpus runs used `--filter` from `$FENCED`. No fenced source or database was run,
  read or decoded, and a grep of this directory for the four names reads 0 0 0 0.
* **Protected paths:** nothing under results/, tests/ (except the regenerated tests/LAWS.md) or third_party/ was
  written. No stash; `GOLDEN_DEFER` unset.
* **Branch drift:** the main tree moved to 6dcc0818 (r11u213) and then a727b8c7d (pass 210) during this
  verification. The source hunks of this patch apply on HEAD; tests/LAWS.md must be regenerated there.

## 6. Files

* [cases/](cases): A (16), B (8), C (7), D (5, multi-file via `args`), E (17), F (8, headers `td.svh` / `te.svh`),
  G (13). Every case names its law in its first line.
* [drivers/](drivers): env.sh, case.sh, j.sh (pristine / law / law OFF), k.sh (pristine / law / fix / switch
  checks), ds.py, census.sh, wide.sh, awayrows.py, det.sh, uvmdist.sh.
* [evidence/](evidence): grid/ (all case-views, the F records and dump names, the wide control), census/ (predicted,
  firings, the frozen fix prediction), movers/ (byteverify, probe movers, the away censuses and their reversed
  controls, the corpus pass switch), downstream/, det/, gates/ (canaries), sweeps/ (the six sweep logs), uvmdist.txt.
* [fix.patch](fix.patch): the refinement alone, against r11u212 as delivered.
