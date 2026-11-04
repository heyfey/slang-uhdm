# v11u478: adversarial verification of r11u478

Pass 478, module/type ground (TaskFuncEmit, UhdmExporter). Base b20e61b5c. The implementer's patch
is /tmp/r11u478.patch (tools/probe/r11u478repro). This folder is the verifier's: 61 fresh attack
case dirs, the drivers, and the evidence.

## Verdict

**CONFIRMED, no break, no production change.** The verified patch's src diff is the
implementer's, byte for byte. Every headline number below was reproduced on a law binary rebuilt
from the patch.

| row | base (master's control /tmp/intr11u476) | law binary |
|---|---|---|
| generated/uvm-examples/uvm_param_vif_config_db.sv | STRICT_NOTEQUAL differ:fullname(3) | **EQUAL**, fresh row `generated/uvm-examples/uvm_param_vif_config_db.sv,EQUAL,,equal` |

On the kept pair (golden from the cache, 1002258 objects):
- pristine: uhdm-cmp 0 lines; uhdm-strictcmp STRICT_NOTEQUAL fullname, 1002253 objects,
  objects_differing=3, walk diverging at #201344 (golden typespec_member `data`, uvm_pkg.sv 255:18,
  against ours an operation at uvm_reg_map.svh 2034:39).
- law: uhdm-cmp 0 lines; uhdm-strictcmp STRICT_EQUAL 1002258 objects.

## Builds and binaries

- Pristine: the main tree's build/slang-uhdm, md5 9aaf4570aa8c469640569b4ba37b874d, frozen at
  /tmp/v11u478_bin/pristine. No pristine build and no pristine sweep (the budget): the pristine
  sweep reading is the master's control /tmp/intr11u476.
- Law: rebuilt once from the patch on a fresh b20e61b5 worktree (`cmake --build build -j 2`),
  md5 d9083f9a10966f02da90e7bba6b1d14b, equal to the implementer's law10, frozen at
  /tmp/v11u478_bin/law. It reports slang 12.0.0+545f88b2e.
- No verified build: nothing changed.

## The law sweep (one full five-stage sweep, law binary, trace on)

Workdir /tmp/v11u478swp (the control's name length). The four corpus stages ran from the
worktree; the sv-tests stage through the main tree's tests/sweep.sh, as the implementer did,
since the worktree's UVM folder is empty. Both sweep commands exit 1 on the law-index check alone:
the worktree's because this folder's new cases were already in the tree (the patch carries the
regenerated tests/LAWS.md), the main tree's because its own index reads stale at b20e61b5. The
implementer's patch applied alone to a fresh b20e61b5 worktree reads "law index current".

| stage | result |
|---|---|
| probe | EQUAL 4025 + STRICT_NOTEQUAL 62 of 4087, regressions 0, conversions 0, changes 0 |
| surelog | default CMP_EQUAL 480, testflags 474; 0/0/0 |
| uhdm2rtlil | 803 / 1 / 67 in both modes; 0/0/0 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not identical and not excused 0 |
| sv-tests | EQUAL 1937, DIFFERENT 3, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, conversions 1, changes 0 |

- The one sv-tests line: `CONVERSION generated/uvm-examples/uvm_param_vif_config_db.sv:
  STRICT_NOTEQUAL -> EQUAL`. The svtests csv equals the control's except that row.
- The probe, surelog, uhdm2rtlil and downstream csvs equal the control's row for row after path
  normalisation (fence-filtered compare, 0 differing lines each).
- Canaries: canaries.sh ok=52 (surelog) and ok=16 (uhdm2rtlil), changed 0; ctcan2 ok=58 changed=0
  (EXPECT_UNKNOWN=1) and ok=2 changed=0 (EXPECT_UNKNOWN=6), both PASS.
- Binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 records name /tmp/v11u478_bin/law
  (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346; no
  record names another slang-uhdm binary.
- byteverify (SELFCHECK=1) against the control, evidence/byteverify.txt: surelog 4 of 962
  (MiniAmiq d/t, SeqDriver d/t, the implementer's md5s exactly: MiniAmiq 3194d2fd5210 against
  8be0993ea71f), uhdm2rtlil 0 of 1608, downstream 0 of 805; the negative control flags 961 of
  962, 1607 of 1608 and 804 of 805.
- The four movers ATTRIBUTED by rerunning the records' commands: MiniAmiq default reads the
  control's bytes with R11U478_OFF=1 and with R11U478_ALIASCOPY_OFF=1 alone, the law's bytes
  with each of the other three switches; SeqDriver testflags reads the control's bytes with
  R11U478_ALIASCOPY_OFF=1. Every verdict kept.
- The trace fired in 27 processes, as the implementer's evidence/trace_counts.txt reads:
  a9_class_holder (PB 4), MiniAmiq and SeqDriver d/t (AF 1 each), rsd (PB 148, SURELOG_CRASH,
  unchanged), uvm_param_vif_config_db (AF 5, AM 6, AP 332, PB 3962) and 21 other uvm-examples
  rows (AF, AM), all EQUAL before and after.

## Each law droppable alone, on the row

The row's command rerun with one switch off (strict against the cached golden):

| switch | uhdm-cmp | strict |
|---|---|---|
| none (law) | 0 | STRICT_EQUAL 1002258 |
| R11U478_ALIASCOPY_OFF | 0 | STRICT_EQUAL 1002258 (see below) |
| R11U478_ARRMEMBER_OFF | 0 | STRICT_NOTEQUAL type, walk diverging at #201344, 1002236 objects |
| R11U478_ALIASPARNAME_OFF | 0 | STRICT_NOTEQUAL fullname, 664 objects from #276776 |
| R11U478_PROVCOPYBIND_OFF | 0 | STRICT_NOTEQUAL depth at #525715, 1002275 objects |

A MEASURED FACT, NOT A BREAK: with the other three laws on, the strict comparator reads the row
equal without § aliasFormalCopyPerClone478. The law is still the one that writes face (d): in the
dumps, golden and the law both hold 4 + 2 references for each of sfr_agent_pkg::, sfr_test_pkg::
and tb_params_pkg::uvm_sequencer_base::set_arbitration::val::UVM_SEQ_ARB_TYPE, while pristine and
the law with R11U478_ALIASCOPY_OFF=1 hold only the sfr_test_pkg one (2 + 1). The strict walk
leaves full names out inside a re-expanded typespec subtree, so once the other faces are closed it
no longer separates this one. The implementer's step table (law2 removes face (d)) is consistent
with that: its law2 carried both the copy law and the array-member law.

## The implementer's grid reproduced (37 dirs, evidence/implementer_grid_repro.txt)

All 74 lines reproduce the implementer's exit code, uhdm-cmp count, strict verdict, object count
and dump distance. Two notes on the goldens: Surelog itself exits 4 on AM/am12 and PB/pb01
(CP0332 `Function "f" is not defined for variable "this"`, its own binder on a class calling an
imported free function); the database is still written and is the golden both READMEs compare
against. The same Surelog error is behind the slrc=4 lines of this folder's VB cases.

The switch table (evidence/switch_table.txt, the first 86 lines over both grids) reproduces the implementer's: R11U478_OFF gives
pristine's bytes on every one of the 37 dirs, each law's own switch alone restores pristine on the
dirs only it moves, and AM/am12 is moved by both ARRMEMBER and PROVCOPYBIND.

## Attack grid (61 fresh dirs in VF, VM, VQ and VB)

Every case is legal SV accepted by upstream slang (`~/.local/bin/slang dut.sv --single-unit`, rc 0
on 61 of 61; VB/vb03 and vb05 were rewritten before any run after a first draft upstream slang
refused). Every exit code of ours is 0 on both binaries. Each case names its law in its first line.
drivers/gen.py and gen2.py write the cases; drivers/runcase.sh measures them;
evidence/attack_grid.txt holds every line, evidence/switch_table_attack.txt the switch table.

Tally, pristine -> law: STRICT_EQUAL 10 -> 20, STRICT_NOTEQUAL 11 -> 1, NOT_EQUAL 40 -> 40.
No dir moves away from golden. Per law:

- **§ aliasFormalCopyPerClone478** (VF/vf01 to vf12). The law fires on 11 dirs; vf03 (an alias of
  an alias of a STRUCT) is the control where it abstains. Every firing dir moves its
  per-package alias names to golden's: vf01 three importers (golden 4 + 2 per importer, law the
  same, pristine only the last importer); vf04 a module importer beside a package importer; vf05
  two alias formals in two functions; vf07 a provider chain; vf08 a file-level import; vf09 a
  default; vf10 a class method plus a free function; vf11 the base enum in another package; vf12
  an explicit import. The enum copy counts move toward golden (vf01: golden 30, pristine 8, law
  18; vf04: 10, 4, 6). The uhdm-cmp head stays at the older face (49 lines) and the dump distance
  grows on vf01, vf02, vf04, vf05, vf08 and vf09 by 3 to 36 lines at the same head, the
  diff-alignment effect the implementer names (*): the names are golden's.
  Residues found, both wrong on pristine too:
  - vf02, three alias levels: golden holds 8 + 4 references per importer, the law 4 + 2.
  - vf06, two alias formals in ONE task (output o and inout io): golden gives EACH formal its own
    copy (i0::t::o::M_T and i0::t::io::M_T), the law one copy per package, named by the last
    writer io. The law's per-package key matches golden for formals of different subroutines
    (r11u231 AL/a04), not for two formals of one subroutine.
- **§ cloneHierArrElemMember478** (VM/vm01 to vm20). Element bindings read with the
  implementer's hpel tool (evidence/tools/hpel.cpp, built against ~/.local's UHDM): the law binds
  the member exactly as golden does on the queue (vm03 a member named `size`, vm15 direct and
  provider importers, vm20 a task writing the element), dynamic (vm09) and associative (vm10)
  arrays. Where golden leaves the element unbound, the law does too: vm02 (a packed array of a
  packed struct inside an unpacked array: UHDM's DeepClone casts the second element ref_typespec
  to a typespec and finds no struct), vm05 (a struct typedef declared in the function), vm07 (a
  package-level array), vm19 (a class property queue). Residues, wrong on pristine too, no byte
  moved by this law: FIXED-SIZE unpacked arrays (`op_t acc[2]`: vm04, vm11, vm12, vm13, vm16 a
  union, vm17), where golden binds the member and ours does not (our element typespec is not the
  struct there, the older face behind the implementer's am07 and am08); a two-dimension array
  (vm01); nested member paths (vm08 `acc[0].b[1].data`, vm18 `acc.b[1].data`) where golden binds
  each member; and golden binds the HOME package's elements too, where the law only touches
  import clones (every VM case: golden's u[top] `data` is bound, ours null).
- **§ aliasCopyParamUnnamed478** (VQ/vq01 to vq18). The law fires on the class-scoped-argument
  shape (pass 470's K::w) and turns 7 dirs STRICT_NOTEQUAL fullname -> STRICT_EQUAL: vq09 one
  argument, vq10 a class-scoped and a literal argument, vq11 the user class in the typedef's
  package, vq12 a module variable, vq13 two user packages, vq15 named this_t arguments, vq18 an
  argument named like the formal; vq14 (int unsigned and bit [7:0] formals) closer, dump distance
  360 -> 312 at an older uhdm-cmp head. It does not fire on vq01 to vq08, vq16 and vq17 (module,
  $unit, nested-class and literal shapes, no registry typedef, a typedef of the typedef): bytes
  unchanged.
- **§ providerBodyCopyBind478** (VB/vb01 to vb11). Fires on 10 dirs, vb02 (two locals of one name
  in two named blocks) the abstaining control. vb03 (a three-level chain), vb08 (two providers)
  and vb10 (an out-of-body class method as the provided subroutine) go STRICT_NOTEQUAL depth ->
  STRICT_EQUAL; the other firing dirs stay STRICT_EQUAL or NOT_EQUAL with bytes moving. It also
  fires on the VM provider cases (package t reaching u through a), every one keeping its verdict.

The switch table over the 61 dirs (evidence/switch_table_attack.txt): R11U478_OFF gives pristine's
bytes on all 47 movers and the 14 others are byte-identical on both binaries; each law's switch
alone restores pristine exactly on the dirs only it moves (ALIASCOPY 11, ALIASPARNAME 8,
PROVCOPYBIND 23, ARRMEMBER 1 (vm20, no provider)); the four VM dirs vm03, vm09, vm10 and vm15 are
moved by both ARRMEMBER and PROVCOPYBIND, as am12 is.

Downstream (drivers/dsgrid.py, scripts/downstream_uhdm2rtlil.py's one(), evidence/downstream_grid.txt):
60 of 61 dirs IDENTICAL on both binaries; VM/vm07 (a package-level array) EQUIVALENT on both
(nohier differs, NO_GATES on both lanes). No dir changes its downstream verdict.

## Away census

- This folder's census (drivers/away.sh, evidence/away_census.txt): the 5504 fence-filtered case
  dirs under tools/probe whose dut.sv holds `class` and no `import`, the complement of the
  implementer's `import` census, since § aliasCopyParamUnnamed478 does not need an import.
  Pristine against law: no exit code moved, 0 dirs moved bytes (5470 at rc 0, 17 at 3, 17 at 4 on
  both). Positive control: the same driver on AP/ap03 and VB/vb01 flags both as movers and AF/af04
  as equal.
- The implementer's 72 movers rerun on both binaries (evidence/implementer_away_movers_repro.txt):
  NOT_EQUAL -> STRICT_EQUAL 5, STRICT_NOTEQUAL -> STRICT_EQUAL 3, STRICT_EQUAL kept 33,
  NOT_EQUAL kept 30, STRICT_NOTEQUAL kept 1; no dir leaves STRICT_EQUAL. The growths are the
  implementer's: v11u241 AR/r03 and r15 +4 uhdm-cmp lines at the same head with the dump distance
  falling, r11u214dec A/d01_clonefn 157 -> 162 and r11u231 TI/t16 112 -> 123 with the full-name
  multiset closer to golden (symmetric difference against golden 6 -> 4 and 4 -> 2).

## Findings that are not breaks

1. § aliasCopyParamUnnamed478 calls `parameter::VpiFullName()` on every candidate before it has
   decided to fire. That generated getter computes and STORES a name when none is stored (the
   pass 468 / 470 / 474 caution). Measured to no effect: evidence/tools/apstored.cpp reads the
   stored symbol id directly, and every candidate parameter in every pristine database of both
   grids and in the row's pristine database (664 candidates) already carries a stored name, so the
   getter never computes there; the switch table shows no dir where ALIASPARNAME_OFF moves bytes
   without the law's trace line; byteverify reads no unattributed mover. The next pass on this
   ground should read the stored name first (as § clsPropSpecFullNameLazy470's storedFullName470
   does) and call the getter only on a firing.
2. The § cloneHierArrElemMember478 comment block in UhdmExporter.cpp is written twice, verbatim,
   above the law. Cosmetic.
3. The row reads STRICT_EQUAL without § aliasFormalCopyPerClone478 once the other three laws are on
   (above); the law is still needed for golden's dump.

## Residues (ranked; all wrong on pristine too, none moved away)

1. § cloneHierArrElemMember478 not reaching fixed-size unpacked arrays of a struct or union
   (VM/vm04, vm11, vm12, vm13, vm16, vm17), two-dimension arrays (vm01), nested member paths
   (vm08, vm18), the HOME package's own elements (every VM case) and the implementer's am07/am08.
2. § aliasFormalCopyPerClone478: two alias formals of one subroutine share one copy where golden
   writes one per formal (VF/vf06); a three-level alias chain where golden holds twice the
   references (vf02).
3. The implementer's residues stand: r11u476's vp06 finding, the interface-instance shapes (IU/iu14,
   VI/vi15, vi16, vi01), AP/ap02 and ap04 at the imported-parameter int_typespec, ap01 and ap05 at
   stage 1, and the toy grids' older listing faces.
4. The carried lists of passes 476 and earlier.

## Sister-ground faces

None new. The implementer's (StmtEmit's § importCloneBodyLocalCopies175 running after the provider
binding is read) stands.

## Goal 1

Re-read at the base: the 75 SURELOG_ONLY rows of results/golden_svtests.csv carry no exporter
`unsupported` message; no SLANG_CRASH row. Nothing on this ground.

## Process

- The fence list was read into a file by a program from canaudit.sh's FENCED= line and never
  printed; every tree-wide list (the census dir list, the sweep csv compares, the cmds.txt audit,
  the byteverify output) was filtered on it before any file was opened or kept. The repro folders
  scan clean.
- The law build, the sweep and the grids ran after the sister r11u485's sweep had ended.
- SLIP, affecting no reported number: the two single-row runner calls on the target row (pristine
  and law, --jobs 1) ran while the sister's verifier (v11u485) sweep was live, and the four
  single-switch reruns of that row while the master's r11u485 integration build was live; one row
  each, single process. The downstream grid and the final grid evidence ran after the master's
  landing sweep had ended.
- SLIP, affecting no measurement: two of the wait loops matched their own shell's command line
  with pgrep -f (caution z1) and so ran to their time limit; the process lists were checked by
  hand before every later launch.
