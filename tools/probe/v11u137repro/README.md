# v11u137 — adversarial verification of r11u137

Verifier of pass r11u137 (the module/type ground on the strict axis: net binding landed from r11u139, the
--elabuhdm clones, packed-array typedef names, spans of calls, ports, prototypes and scalars). Base `8e8d2643`,
branch matrix-1.87. **Verdict: ACCEPT-WITH-FIX.** Every headline number reproduces bit for bit; two law faces
moved a record away from golden on legal SV (found by this pass's break grid, invisible to the corpora and
the probe set) and are fixed here under their own switches; six grid cases named a law that does not exist.

| binary | md5 | what |
|---|---|---|
| pristine | `eb9bed7afbf4f8c4f918e1de172fc4f8` | built here at 8e8d2643 (= the main tree's pristine) |
| r11u137 | `32aa0e2f4f816cd93c21c7ce13ef93f3` | built here from the implementer's patch (= its README) |
| verified | `f38dd8dd56941060889e38995d1ee43e` | this patch (r11u137 + the two refinements below) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | built here, = the main tree's |

Every binary was frozen (`chmod 555` copy) before it measured anything. cmds.txt audit: the pristine sweep
names the frozen pristine binary on 3273 of 3273 slang runs, the r11u137 sweep the r11u137 binary on 3273, the
verified sweep the verified binary on 3273 (the other 50 corpus runs never run slang-uhdm). The downstream lane
records no command line: five target databases re-derived with the verified binary are byte-identical to the
sweep's, and all 24 target databases differ from the pristine binary's.

## 1. Reproduction of the implementer's numbers (all bit for bit)

* probe: `EQUAL=2183 STRICT_NOTEQUAL=1904 (of 4087)`, `regressions=0 conversions=44 changes=93`.
* surelog: `[default] CMP_EQUAL=386 ... STRICT_NOTEQUAL=94`, `[testflags] CMP_EQUAL=381 ... STRICT_NOTEQUAL=93`,
  `regressions=0 conversions=63 changes=25`; uhdm2rtlil `CMP_EQUAL=684 CMP_NOTEQUAL=1 SLANG_REJECT=67
  STRICT_NOTEQUAL=119` both modes, `regressions=0 conversions=48 changes=20`. Strict-equal row-modes surelog
  704 -> 767, uhdm2rtlil 1320 -> 1368; the judge scoreboards stay 480/3 + 474/3 and 803/1/67.
* own pristine sweep: regressions=0 conversions=0 changes=0 in both corpora (704 / 1320).
* strict column, law vs pristine row by row (evidence/strict_census.txt): surelog 63 conversions, 16 fewer on the
  same field, 3 first-field moves, 6 more on the same field; uhdm2rtlil 48 / 16 / 4 / 0; no row leaves `equal`,
  no status change. drivers/rowcmp.py walks golden against pristine and against the law database record by
  record: on all 45 changed non-converted corpus row-modes and all 93 changed probe cases, **no record that
  the pristine walk matched (before the first structural divergence of either walk) differs in the law walk**
  (evidence/fewer_out.txt, probechg_out.txt). The six "more" rows are unmasks: the pristine walk diverged
  (YosysOldOr at record 88173 of 243334, YosysOldOpen 12377, YosysRiscv 3390, DelayAssign 513) and the law walk
  no longer diverges at all, so records past the old divergence are compared for the first time.
* byteverify (SELFCHECK=1, same-length workdirs): PATH_SETS_IDENTICAL, SELFCHECK 959/960 and 1607/1608, MOVERS
  128/960 + 76/1608. The r11u137 binary with `R11U137_OFF=1` rerun on every mover test gives the pristine bytes
  on 199 of 204 mover databases (evidence/attribution_R11U137_OFF.txt); the other five (MiniAmiq d/t, SeqDriver
  d/t, Scoreboard d) read 4, 4, 4, 4, 0 order-blind dump lines: the UVM order coin. No slang-fenced test moves.
* the implementer's grids: 111 cells (the README says 110: grid hb08 was added after its table), strict-equal
  pristine 28 (the README headline says 29; its own per-grid column sums to 28) -> 81, every cell keeping rc
  and uhdm-cmp line count; the r11u139 grid 98 cells 37 -> 87, same as the analyst's law.patch.
* canaries (final binary vs pristine): surelog ok=42 changed=10 (FuncStruct t, YosysBigSimReed d/t conversions;
  FuncIoTypespec, BasicOh d/t fewer; YosysOldOr d/t, YosysOldOpen d/t the unmasks above), uhdm2rtlil ok=16
  changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: changed=2 = the conversions TypespecExpr t, EvalFuncNamed t
  (the script reads any move as FAIL); `EXPECT_UNKNOWN=6` uhdm2rtlil PASS.

## 2. Findings

**F1 (fixed) — § unsignedScalarVecTsAtKeyword137 moves the DEFINITION view of a `wire logic unsigned` body net
away from golden.** Golden spans a body net declaration with an explicit net type differently per view:
`wire logic unsigned w;` reads 3:8-3:22 (`logic unsigned`) under the definition module and 3:8-3:13 (`logic`)
under the elaborated one. Pristine wrote 3:22 in both (elab wrong); the law wrote 3:13 in both, so the
definition record the pristine walk MATCHED now differs (grid wcases: w01 top, w02 sub-module, w04 `tri`, w05
with an initializer, w07 interface, w10 two declarators: strict count 1 -> 2 or 2 -> 4). Ports (w03 ANSI
`input wire logic unsigned`, w06 non-ANSI body re-declaration) and variables take the keyword in both views.
Fix: the law skips a body `NetDeclaration` net while the definition view's net typespec is built
(`defNetTsScope` set, no port context); switch `R11V137_DEFWIRE_OFF`. wcases: pristine 1, r11u137 2, verified
**9 of 9** judge-equal cells strict-equal. No corpus row or probe case carries the shape (grepped: no mover).

**F2 (fixed) — § pureVirtProtoSpan137 ends a pure virtual function at its LAST qualifier; golden ends it at
`virtual`.** `pure virtual protected function int f();` golden 3:3-3:15, the law 3:3-3:25 (pristine 3:29, both
wrong). Fix: end at the `virtual` qualifier token when present (switch `R11V137_PVQUAL_OFF`). pcases: 5 of 5
judge-equal cells strict-equal (law 2). Predicted and measured corpus movers (final vs law): the UVM 1.2 rows
carrying `uvm_recorder`'s `pure virtual protected function`s: BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t,
SimpleUVM d/t, Scoreboard d (9 of 960; uhdm2rtlil 0 of 1608); on each the function spans move from golden-wrong
(endln 25013:26) to golden's value (25013:16); their strict cells (first field line) are unchanged.

**F3 (fixed) — the six `grid/pv` cases named `§ pureVirtTaskEndsAtParen137`, a law that exists nowhere**, so
tests/LAWS.md listed no case for § pureVirtProtoSpan137. Restamped; the index now lists them.

**F4 (fixed, bookkeeping)** — the implementer README spelled a slang-fenced test's name (residue S3); reworded.
Its grid cell count (110 -> 111) and pristine grid count (29 -> 28) are corrected here. The fence check of the
integration cycle hits two implementer evidence files through a uhdm2rtlil test whose name contains a fenced name: a substring false
positive with precedent in committed evidence.

**F5 (note)** — tests/LAWS.md at the base itself reads STALE (`law_index.py --check` at 8e8d2643, rc=1); with
this patch it reads current. **Landing note:** HEAD (d8473d78) already holds tools/probe/r11u139netbind from
e98516a3; this patch adds that directory against 8e8d2643 with the case first lines stamped, so the integration
must take the stamped versions over e98516a3's (the law.patch, README and evidence are the same files), and
pass 133 (d8473d78) sits between: re-measure there.

The implementer's own rule breach (a gdb run on a scratch copy of a fenced test's source) cannot be verified
from artifacts: nothing in the patch or its evidence names the test, as it states.

## 3. The break grid (brk/, every case names its law in its first line)

Fresh instances per face, scored by drivers/score.py (Surelog `-parse -nobuiltin -nocache -sv dut.sv -mt 0
-mp 0`, ours `dut.sv --single-unit --nobuiltin`, `--elabuhdm`/`-elabuhdm` on both sides for the elab law):
uhdm-cmp line count, rc and the strict verdict for pristine, r11u137 and the verified binary (evidence/score*).

| law | cells | judge-equal | strict-equal pristine | r11u137 | verified |
|---|---|---|---|---|---|
| § unsignedScalarVecTsAtKeyword137 (brk/cases a*, brk/wcases) | 24 | 22 | 1 | 11 | 18 |
| § pureVirtProtoSpan137 (brk/cases f*, brk/pcases) | 12 | 9 | 0 | 3 | 7 |
| § packedArrTdElemRefName137 (b*) | 8 | 3 | 0 | 3 | 3 |
| § emptyNamedConnLowConnAtDecl137 (c*) | 8 | 7 | 0 | 7 | 7 |
| § constCallNameSpan137 (d*) | 10 | 4 | 2 | 4 | 4 |
| § connReplTsRefThroughPort137 (e*) | 5 | 5 | 0 | 4 | 4 |
| § taggedUnionElabSpan137 (g*) | 3 | 3 | 1 | 2 | 2 |
| § defNetTypeParamDefault137 (h*, brk/tcases) | 14 | 10 | 0 | 5 | 5 |
| § aliasCloneTakesTargetFile137 (i*) | 3 | 2 | 0 | 1 | 1 |
| § defNetScopedPkgArrTdShares137 (j*) | 8 | 2 | 0 | 2 | 2 |
| § structParamPathBaseAtMember137 (k*, brk/kcases) | 13 | 10 | 1 | 7 | 7 |
| § elabCloneFullNameUnstored137, --elabuhdm (l01-l07, brk/ecases) | 13 | 10 | 2 | 10 | 10 |
| § caLhsDefNetUnlessOpRhs139 / § ndaLeftmostLeafElab139 / § connLeftmostLeafElab139 / § clockingEventDefNet139 (m*) | 9 | 9 | 3 | 9 | 9 |

(l01-l07 without --elabuhdm are controls: unchanged except l06, whose `wire [3:0] w = a + 4'd1;` in a
sub-module converts under § ndaLeftmostLeafElab139.) Every cell keeps rc and uhdm-cmp line count across the
three binaries; no cell moves from strict-equal to not. Beyond F1/F2 no recorded field moves away from golden.
Examples of the breadth: the elab law holds on for-loop and named-block locals, interface modport task imports,
static function variables, parameters in sub-module processes (l08-l11); the struct-parameter path base holds
under a gen-case, a gen-for bound, a gen-if inside a gen-for, two paths in one range, an imported package
parameter, and a stale-scope trap (top declares a net with the parameter's name, k10); the empty connection
holds for non-ANSI vectors, a comment inside `()`, generate blocks, two levels, an explicit port expression and
a parameterized child.

Residues met on the laws' faces (pristine-wrong, not worsened): the attribute start of a prototype
(f04 `(* keep *)`: col), a non-pure `virtual function` with a body (f05: golden ends at `virtual`, ours at
`endfunction`: TaskFuncEmit, the next pv face), the replication inside a concatenation actual (e01: golden's
ref_typespec reads no name at all), a package typedef's bit_typespec name (a14 `p::pb_t`), type-parameter port
copies of the default typespec (t01-t03: one shared object in golden), the interface type-parameter net (t05).

Switches (evidence per case): `R11V137_OFF` gives the r11u137 bytes on every wcases/pcases/a*/f* cell, each of
`R11V137_DEFWIRE_OFF` / `R11V137_PVQUAL_OFF` drops only its own face, `R11U137_OFF=1` gives the pristine bytes.

## 4. Gates of the verified binary

1. build: pristine `eb9bed7afbf4`, verified `f38dd8dd5694`.
2. probe: `EQUAL=2183 STRICT_NOTEQUAL=1904 (of 4087)`, `regressions=0 conversions=44 changes=93`, csv identical to
   the r11u137 sweep's.
3. corpora: identical tallies and csv rows to the r11u137 sweep (`regressions=0`, conversions 63 / 48, changes
   25 / 20); sweep rc=0 (law index current).
4. downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`; verdict
   and `differs` equal to results/downstream_uhdm2rtlil.csv on 871 of 871 rows; the 24 converted uhdm2rtlil tests
   read IDENTICAL with moved databases.
5. byteverify verified vs r11u137: surelog MOVERS 9/960 (the predicted UVM rows of F2), uhdm2rtlil 0/1608.
6. canaries as in section 1.

## 5. Files

* `brk/{cases,wcases,pcases,ecases,tcases,kcases}/<case>/dut.sv` — the break grid (i03 carries `s.svh`).
* `drivers/score.py` (one grid, pristine / law / verified, optional `--elab`, `--env`), `drivers/rowcmp.py`
  (golden vs two databases, record by record), `drivers/gen.py` (writes brk/cases).
* `evidence/` — score_*.tsv / s_*.tsv (grids), strict_census.txt, fewer_out.txt, probechg_out.txt,
  byteverify_*.txt, attribution_R11U137_OFF.txt, sweep_{P,L,F}.txt.
