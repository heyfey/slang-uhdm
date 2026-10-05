# v11u251: adversarial verification of r11u251 (pass 251, the module/type ground)

Base 084d871b (`matrix-1.87`), the implementer's patch /tmp/r11u251.patch (md5 76209a0069bed11df8950569d811ad30)
applied clean on a fresh worktree. **Verdict: VERIFIED, no production fix.** Every headline number of the
implementer reproduces bit for bit. Fresh cases found no shape that pristine got right and the law gets wrong. This
directory adds only cases, drivers and evidence; nothing under src/, results/ or third_party/ changes.

## Binaries (built by the verifier, frozen before any measurement)

| binary | md5 |
|---|---|
| pristine (fresh 084d871b worktree, system-deps cmake config, -j 2) | 188f251c2aa8e23a6af95a77909eec69 (equal to the brief's) |
| law (084d871b + r11u251.patch) | 6de2dcb040105726241878705123de02 (equal to the implementer's) |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 |

Both binaries link slang 12.0.0+545f88b2e and UHDM 1.87.

## Reproduction of the implementer's numbers

* **Sweeps** (tests/sweep.sh --jobs 3, pristine from the pristine worktree into /tmp/v11u251_wdP, law from the law
  worktree into /tmp/v11u251_wdL; `evidence/sweep_*_summary.txt`):
  * probe: pristine EQUAL 3539 + STRICT_NOTEQUAL 548; law **3543 + 544, regressions=0 conversions=4 changes=0**.
    The four are `r10uvm46repro/t63a`, `t63c`, `t63d`, `t63e`, each now `EQUAL,,equal`. Before, they read
    STRICT_NOTEQUAL fullname(10), (20), (10) and (10).
  * surelog: law default CMP_EQUAL 471 + STRICT_NOTEQUAL 9, testflags 466 + 8; **regressions=0 conversions=1
    changes=2**:
    * **CONVERSION** `Scoreboard,default,CMP_EQUAL,,,equal` (base `differ:col(5)`);
    * CHANGE SimpleUVM default and testflags `differ:col(5)` -> `differ:value(50)`.
  * uhdm2rtlil 803/1/67 in both modes, 0/0/0. Downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0
    DIVERGENT on both binaries.
  * Both sweeps exit 1 only on `law index STALE`. On the pristine worktree this is the base's own LAWS.md, which
    cannot name its own commit (`clsPropWholeArrTd249` commits: none -> 084d871b2). On the law worktree it is also
    this directory's cases. The index is regenerated last.
* **Row-for-row csv diff, pristine against law** (`evidence/csv_diff_pristine_law.txt`): the 4 probe rows, the 3
  surelog rows above, and the 2 LowMem log-path text rows (environment). uhdm2rtlil and downstream have 0 rows.
* **byteverify** (SELFCHECK=1, on fence-filtered hard-link mirrors from drivers/bvmirror.sh; mirrored=2560,
  fenced_skipped=8 each; `evidence/byteverify.txt`):
  * PATH_SETS_IDENTICAL; **MOVERS 9 / 2560**; SELFCHECK 2559 / 2560 flagged;
  * the movers: BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t, SimpleUVM d/t, the implementer's 9.
* **Probe databases.** These embed the worktree path, so the pristine probe stage was rerun from the law worktree
  (/tmp/v11u251_wdQ; its csv is equal to wdP's row for row). 4 of 4087 move, the four conversions.
  **Downstream slang lanes**: 0 of 805 move. Both path lists were filtered by $FENCED before any compare.
* **cmds.txt audit** (fence-filtered list of 3315 per sweep): wdP names pristine.bin in 3265 and law.bin in 0; wdL
  names law.bin in 3265 and pristine.bin in 0. Neither names the main tree's build/slang-uhdm.
* **Away census** (drivers/away.py, chain records, depth dropped; `evidence/away_corpus.txt`): **lost=0 on all 9
  corpus movers**.
  * Gained per row-mode: BuildUVMPkg 2, MiniAmiq 3, SeqDriver 3, Scoreboard 3, SimpleUVM 13.
  * Positive control: SimpleUVM default with the binaries swapped reads `lost=13 gained=0`.
* **SimpleUVM's head after the law** (build/uhdm-strictcmp on the law sweep's database):
  * the first record is `#203342 value  A: parameter UVM_ABSTRACT work@top.UVM_ABSTRACT uvm_object_globals.svh
    201:11-201:23 UINT:16384 | B: the same with no value`;
  * `fields: value=50 objects_differing=50`;
  * pristine's first records were #194836 col (golden 270:51, ours 270:42) and #201235 fullname
    (`uvm_pkg::uvm_resource_types::override_e` against `override_e`, walk diverged).
  * The implementer's decode/HP h01 and h02 read STRICT_NOTEQUAL value on both binaries, and h03 STRICT_EQUAL on
    both. This confirms the sister-ground attribution: ParamEmit, the module copy of a `$unit`-imported package
    parameter.
* **Canaries**: surelog ok=49 changed=3. The three are SimpleUVM d/t (col(5) -> value(50)) and Scoreboard d
  (-> CMP_EQUAL/equal). uhdm2rtlil ok=16 changed=0. ctcan2 EXPECT_UNKNOWN=1 on the surelog csv: PASS (ok=58).
  ctcan2 EXPECT_UNKNOWN=6 on the uhdm2rtlil csv: PASS.
* **Determinism** (drivers/det.sh, three concurrent harness runs per binary; `evidence/det.txt`): one hash per
  row-mode on Earlgrey_0_1 and the five UVM rows, 11 of 11 for both binaries. Every law hash equals the sweep's
  database: MiniAmiq 0212d91c4100, SeqDriver d 20aed5cf4333 / t 7b614719b801, SimpleUVM d 69b26be136be / t
  9b63845ee589, Scoreboard d dbed01280a79, BuildUVMPkg 12c73cb9b60c. Scoreboard testflags has no database on
  either binary, as at the base.
* **The implementer's grid rerun** (its drivers/grid.sh on the verifier's binaries, 2046 lines;
  `evidence/implementer_grid_rerun.txt`):
  * every line equal in cmp, cmplines, strict and rc, and every case equal in which configurations write pristine
    bytes and which write the law's (drivers/cmpgrid.py: mismatch 0);
  * 186 case-views, 120 moved, 88 entering STRICT_EQUAL, 0 leaving; R11U251_OFF pristine bytes on 186 of 186.
  * One README misstatement: the grid's non-zero exits are g24 AND IN/i07 (exit 4 in both views on both binaries,
    8 case-view-binary pairs), not only g24's 4 lines. The README's own table names i07 as exit 4.
* **The implementer's byte controls rerun** (its 26 repro dirs, 3470 case-views, 6940 lines;
  `evidence/controls.txt`):
  * every line equal to the implementer's (mismatch 0);
  * 40 move, 24 enter STRICT_EQUAL, none leaves;
  * exits: 6866 rc=0, 36 rc=3, 36 rc=4, and 2 rc=139 (r11v124repro hx/x02_forstep elaborated, both binaries,
    pre-existing).
  * The stage-1 movers with an unchanged line count were each measured with the dump-line away census
    (drivers/awaydump.py). t63f, Q/q03, q05, V191/qr01, qr02 and v11u249 M/m01 lose 0.
  * V191/qr2 (exit 4 on both) "loses" 3 generic lines (`|vpiTypedefAlias:`, `|vpiParent:`, `|vpiActual:`). These
    are pristine's tq_t return-twin alias, which golden does not write. In a multiset with ids stripped they
    matched golden's bq_t/nq_t alias lines. The law agrees with golden on tq_t (no alias).
  * v11u247 K/k03 "loses" 3 constant lines (the folded INT:1 bound of the copy pristine bound for r). The law binds
    the shared r2_t listing with its `2 - 1` operation, as golden does.
* **Widened byte controls** (six more dirs: r11u246repro, v11u246repro, r11u244repro, v11u244repro, r11u241repro,
  r11u239repro; 936 case-views, 1872 lines; `evidence/controls_wide.txt`): **0 move**. Exits: 1848 rc=0, 4 rc=3,
  20 rc=4, each identical on both binaries.

## The attack (79 fresh cases, `cases/`; each first line names its law; drivers/vgrid.sh)

Every case runs in both views on pristine, law, law + R11U251_OFF and law + its group's own switch. The EB group runs
in the builtin mode (NB=1: no `-nobuiltin` / `--nobuiltin` in either lane), because § clsEnumBaseRefFullName251 runs
only there and none of the implementer's cases reached it. That gives 662 lines, each with its exit code
(`evidence/grid.txt`, `evidence/grid_summary.txt`). The downstream verdict uses scripts/downstream_uhdm2rtlil.py's
one() on every case outside EB (`evidence/ds_cases.txt`).

**Totals.**
* 158 case-views; **116 move, 74 enter STRICT_EQUAL, 0 leave**.
* **R11U251_OFF gives pristine bytes on 158 of 158.** Each group's switch gives pristine bytes on every moved
  case-view except the four where two laws combine (RN v11: REGNET with IFDYNNT; IN v04, v07, v08, v11: IFDYNVAR
  with IFDYNNT or REGNET; RT v01: RETTWINALIAS with CLSTDIDXLOC on an `[int]` index).
* Exits: 632 rc=0 and 30 rc=4 (IN v05 enum element, v06 two-level dynamic, v13 packed-struct element; identical on
  both binaries). SC v10 (an escaped quote in a stringification) is a SURELOG_FAIL and is kept as a record.
* **Downstream** (69 cases): pristine 37 IDENTICAL / 27 EQUIVALENT / 4 STATUS_DIFF / 1 SURELOG_FAIL; law
  **55 / 13 / 0 / 1**; **no case leaves IDENTICAL**. 18 cases move to IDENTICAL. RN v01, v05 and IN v08, v11 go
  from STATUS_DIFF.
* **Away census** on every moved case-view that does not reach STRICT_EQUAL (`evidence/away_cases.txt`;
  record census where stage 2 runs, dump-line census where stage 1 rejects): lost=0 everywhere except RN v06 and
  v14 (1 generic `\_constant:` line each: pristine's folded bound in a context golden prints elsewhere; the net
  placement and port nets move to golden's, 7 and 11 dump lines toward).

| group / law | cases | result |
|---|---|---|
| RN § regTdArrElabIsNet251 | v01 packed reg element, v02 `reg signed` dynamic, v03 package typedef imported at $unit, v04 two instances two levels down, v05 `[string]` index, v06 ANSI input port, v07 function and task locals (control), v08 `static`, v09 class property beside a module variable, v10 module-body typedef in two instances, v11 reg queue in an interface with a modport, v12 typedef of a reg typedef (control), v13 non-ANSI `output r_t o`, v14 two declarators with an initializer, v15 non-ANSI port with a separate data declaration, v16 named-block local (control), v17 between wires and a logic variable | STRICT_EQUAL: v01, v02, v04, v05, v08, v09, v11, v17. Controls v07, v12, v16 unchanged (no firing). Stage 1 on both, moving toward golden: v03 (package listing, sister ground), v06 (port typespec, implementer g12), v10 (module-body tail clones), v13, v15 (definition-view port face), v14 (golden's net-decl cont_assign, implementer g10). |
| IN § ifaceDynTdElabVar251, § ifaceDynAliasNetType251 | v01 string queue, v02 int `[int]`, v03 bit dynamic in two instances, v04 instance array, v05 enum element, v06 two-level dynamic, v07 modport port view, v08 generic interface port, v09 package typedef imported in the body, v10 class element, v11 reg associative plus logic dynamic, v12 generate block, v13 packed-struct element, v14 uninstantiated interface, v15 the module road's twin of v10 (control) | STRICT_EQUAL: v02, v03, v04, v08, v11; v14 equal on both. Exit 4 on both: v05, v06, v13. Stage 1 on both, moving toward golden: v01 (18 lines toward), v07 (the home view now right; golden also lists `q` in the modport port view, which the law leaves alone), v09, v10. v12 does not fire. |
| SC § ppStrEndNotTokStart251 | v01 end on a reference, v02 one short (control), v03 across a continuation line, v04 two literals with a paste, v05 stringification in a macro argument, v06 in an included header, v07 CRLF, v08 inactive `ifdef branch, v09 on the next statement's lvalue, v10 escaped quote | STRICT_EQUAL: v01, v06, v07, v08, v09 (col -> equal in both views). v03 and v04 fire with no byte change (v04's endcol face is pre-existing). v02 and v05 do not fire. v10 is a Surelog failure. |
| AI § clsTdAssocIdxKwLoc251 | `[shortint]`, `[longint]`, `[integer]`, `[byte]`, `[int unsigned]`, `[bit [3:0]]` (control), a package-level, a module-body and a $unit typedef (none a class typedef), a non-parameterized $unit class with a `string` element, a spaced and commented index | STRICT_EQUAL: shortint, longint, integer, byte, int unsigned, spaced (the implementer's a08 byte face is not reproduced here: these cases declare a property, a08 a ref formal). Not class typedefs: no firing. v_unitcls_nonparam: stage 1 on both, 6 lines toward. |
| RT § dynTdRetTwinNoAlias251 | `[int]` associative, extern out-of-body, specialized and called, derived class returning the base's typedef, two type parameters, packed-vector default with queue and dynamic, a value parameter (control) | STRICT_EQUAL: v04 (type -> equal in both views). v01 col -> fullname (golden's `[int]` index reference name in the twin, the implementer's r01 face; 10 -> 0 records off golden, lost 0). v02, v03, v05, v06 stage 1 on both with 7 to 21 dump lines toward. The control does not fire. |
| BP § bindIfacePortRefDefName251 | target in a generate block, implicit `.clk`, two interfaces in one bind, an internal variable actual, a localparam actual, an instance array target, a parameterized interface, the target three levels down, a parent signal with the port's name | STRICT_EQUAL: v02, v04, v06, v08, v09 (fullname -> equal). Stage 1 on both: v03, v05, v07 (8 lines toward each), v01 (see residue 2). |
| EB § clsEnumBaseRefFullName251 (builtin mode) | package class with a keyword base and a typedef base, $unit class, module class, a class specialized twice, a nested class (control), an interface class, use only as a method formal, a program class, no explicit base | STRICT_EQUAL: v01, v02, v03, v04, v05, v08, v09 (fullname -> equal in both views). v10 does not fire and is equal on both. v06 does not fire and is fullname on both. v07 moves fullname -> fullname (see residue 3). |

## Findings

No case breaks a landed law or moves a cell from right to wrong. The residues below were wrong on pristine too.

1. **IN v10 / v15: a `$unit` class-element queue typedef.** Golden lists the elaborated variable as a `class_var`.
   The module road (v15, pristine and law alike) writes an `array_var`. § ifaceDynTdElabVar251 now writes the same
   `array_var` on the interface road, where pristine wrote nothing. 10 dump lines move toward golden and 8 of ours
   that golden lacks are added (the kind). This is pass 249's residue (1)(b) (class elements, unitDynTdShape249),
   on both roads. When that face is written, the interface branch must follow it.
2. **BP v01: a bind target inside a generate block.** Golden names the bound interface's port references on the
   generate scope (`work@top.g.add_sub_if0.clk`, `work@top.g.a0`). Pristine wrote `work@top.g.dut...`, and the law
   writes `work@top.add_sub_if0.clk` and `work@top.a0`, because parentM skips the gen scope. The case is stage 1 on
   both (517 lines), with 0 lost and 0 gained. The site is § bindIfaceTwinInParent46's parent path, which the law
   reuses.
3. **EB v07: a class declared inside an interface.** Golden names the enum base reference `work@c::e_t` (the $unit
   form). The law writes `work@ifc::c::e_t`, because the InstanceBody branch assumes golden's module form
   `work@top::c::e_t`. Pristine wrote `e_t`, so this is wrong on both, with 0 lost. The program form (v09) is right.
   EB v06 (a nested class) is not reached.
4. Carried from the implementer and confirmed:
   * BuildUVMPkg d/t depth(1) #185844 (unchanged);
   * Rggen d and Earlgrey_0_1 d/t (no law fires);
   * law 1's open shapes: the initializer's cont_assign (v14 = g10), port typespecs (v06 = g12), module-body tail
     clones (v10 = g07), package listings (v03 = g08, sister ground);
   * law 8's bit-select actual;
   * law 7's index reference full name (RT v01 = r01).
5. Sister ground (reported, not written): SimpleUVM d/t value(50), the 50 `work@top.UVM_*` module copies of
   `$unit`-imported uvm_pkg parameters lacking golden's folded value. ParamEmit's imported-parameter mint
   (`up->VpiImported(occ9 ...)`); the implementer's decode/HP h01 and h02 reproduce it and h03 is equal.

## Process

* **Fence**: nothing fenced was dispatched, read or opened outside the two gate sweeps. Mirrors, the cmds.txt
  audit, the probe and downstream byte compares and the away census filter their path lists by $FENCED first.
  * drivers/away.py and drivers/awaydump.py now read $FENCED fail-closed. The implementer's copy of away.py had no
    fence check; its caller awaycorp.sh filtered first, so nothing fenced was opened.
* **One slip, recorded.** One inspection loop ran in a fresh shell where UHDM_DUMP had not been exported. Bash then
  tried to execute two case databases and a case golden under /tmp/v11u251_S/g (BP/v01_gen_target) as scripts.
  Each failed on a syntax error before any redirection. A search of the scratch tree and the main checkout's root
  found no new or empty file. From then on every shell sourced a guarded env file (`[ -x ]` on every tool). No
  corpus database was involved.
* No process of another agent was listed or signalled; no `pgrep`/`pkill` was used. Everything was written under
  /tmp/wt_v11u251, /tmp/wt_v11u251pris and /tmp/v11u251_* only.

## Drivers (`drivers/`)

* Copied from r11u251repro, each with a fence check: `env.sh`, `case.sh`, `grid.sh`, `controls.sh`, `det.sh`,
  `bvmirror.sh`, `tracesweep.sh`, `dscases.py`, `awaycorp.sh`, `awayrows.py`, `away.py`.
  * `case.sh` gains NB=1, the builtin mode keyed `_nb`, and a `trace` tag that makes the R11U251_TRACE directory.
  * `away.py` gains the fence check.
* `awaydump.py` (from r11u248repro, plus the fence check): the dump-line census for stage-1 case-views.
* New:
  * `vgrid.sh`: this directory's grid;
  * `vgridsum.py`: per case-view verdicts, OFF and switch byte checks, and enter/leave counts;
  * `cmpgrid.py`: compares two grid files field by field and by configuration pattern.
