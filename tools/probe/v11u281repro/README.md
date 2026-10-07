# v11u281 — adversarial verification of r11u281 (module/type ground: type-parameter arrays and interface type parameters)

Base aa8941fd (pass 279). The implementer's patch (five laws in UhdmExporter behind `src/R281.h`) was applied to a
fresh worktree, both binaries were built and frozen, every headline number was reproduced, and 82 fresh case dirs
(164 case-views) attacked the five laws. **VERDICT: two breaks on legal SV where pristine was right, both FIXED
behind their own switches (two refinements); with the fix every gate number is the implementer's, bit for bit: the
fix binary's gate sweeps are byte-identical to the law's (0 of 952 surelog, 0 of 1608 uhdm2rtlil, 0 of 805
downstream and 0 of 4087 probe databases differ).**

| | pristine | law (r11u281) | law + this fix |
|---|---|---|---|
| md5 | 11a220f100aa6c0856c4f6cc80047c0d (= the brief's) | f3468624ca02fe42d6908210227fa7e3 (= the implementer's) | e0aeb5ac690a22c9bb8a5b12ea68d6c0 |
| probe | EQUAL 3797 + STRICT_NOTEQUAL 290 | **3809 + 278**, regressions 0, conversions 12, changes 2 | the same, csv identical |
| surelog d/t | 478 + 2 / 472 + 2 | the same, 0 / 0 / 0 | the same |
| uhdm2rtlil d/t | 803 / 1 / 67 each | the same | the same |
| downstream | 803 / 66 / 2 / 0 | csv byte-identical to pristine's and to the baseline | the same |
| fresh grid, case-views moving / entering STRICT_EQUAL / leaving | | 150 / 80 / 0 | 142 / 86 / 0 |
| fresh grid, chain-keyed away | | **8 case-views away (vn08, vn14, vn15, vn16)** | 0 on all 142 movers |
| fresh downstream, a verdict worse than pristine's | | **vn14 IDENTICAL -> DIVERGENT, vi34 EQUIVALENT -> DIVERGENT** | none |

## The two refinements (src/R281.h, `r11v281On`; `R11V281_OFF` gives the law's bytes, `R11U281_OFF` still gives pristine's)

1. **§ tpPatNestNamedChain281v** (UhdmExporter, inside § defNetTpPatNestedSig281's route in
   § defNetTpDimLastInstPat275; switch `R11V281_PATNAMED_OFF`; trace `PATNAMED281V_ABSTAIN`). The law's nested route
   (an unpacked or extra packed dimension on the net) took the last instance's array whatever bound its element, so
   an ORDERED override (`child #(logic [1:0]) u` with `rt_t x [2];`) moved the definition net's element from the
   default `logic` 2:38-2:43, which golden keeps (an ordered override registers nothing in getTypeParams(); the
   elaboration that compiled the declaration bound the default), to the ordered binding 8:11-8:22. Measured on
   VN/vn08 (`rt_t x [2]`), vn14 (`rt_t [1:0] x`), vn15 (a named then an ordered instance) and vn16, in both views:
   chain-keyed away 1 or 2 on each of the 8 case-views (stage 1 on every binary, Surelog ignoring the ordered type
   override everywhere), and vn14 downstream **IDENTICAL -> DIVERGENT**. The fix reads a named override of the
   element on the instance or an ancestor, the test § tpRebindSpanDiffers281 already applies (ovr120, the
   type-reference set tyRef281 too), and abstains otherwise. vn17 (a parent's named override passed down to the
   child in order) still converts, as golden does; the plain-net control vn13 never moved.
2. **§ ifTpUseMultiDeclShared281v** (UhdmExporter § ifaceTpUseBindsDefDefault281; switch `R11V281_MULTIDECL_OFF`;
   trace `MULTIDECL281V`). `T d, q;` in an interface writes ONE instance typespec at the type token, parented at one
   declarator, which every declarator's reference reads; the law required the typespec's parent to be the signal
   itself, so it rebound one declarator and left the other a 1-bit bare `logic`. VI/vi34 (`T d, q;
   always_comb q = ~d;`): the law fixed q to 4 bits and left d at 1, downstream **EQUIVALENT -> DIVERGENT** (pristine
   had both at 1 bit, consistently). The fix also rebinds a reference whose typespec is parented at another signal of
   the same instance that reads the same object (the references are snapshotted before the scope's rebinds, so the
   declarator order does not matter). vi28 (`T d, e;`), vi34 and vi36 (`T a, b, c;`) enter STRICT_EQUAL in both views
   and every multi-declarator case reads IDENTICAL downstream (vi28, vi34, vi36, vi37 `wire T a, b;`, vi38 two
   instances).

## Reproduction of the implementer's numbers (frozen binaries under /tmp/v11u281_bin, own worktrees, own workdirs)

- **Builds**: pristine 11a220f1 equals the brief's md5; law f3468624 equals the implementer's; both link slang
  12.0.0+545f88b2e; uhdm-strictcmp fa6e4f42 in both worktrees.
- **Gate sweeps** (`tests/sweep.sh --jobs 3`, workdirs /tmp/v11u281_P, _L, _F, equal length): probe pristine 3797 +
  290 regressions 0; law 3809 + 278 with the same twelve conversions and two changes by name
  (r11u110repro/grid/e1/e25_ovr_same_ctl line(4), r11u110repro/grid/f2/i09_unpacked_child_ovr line(2) and
  i11_attr_wdims_child line(2), r11u20repro/t6, r11u47repro/arms/g9, r11v47repro/arms/v7,
  r11v53repro/grid/x10_iface_import_shadow and v11u113repro/grid/f2/t03_iface_tp fullname(2),
  v11u110repro/brk/v1/a11_bit_vs_logic line(20), c08_unpacked_2state_elem_ovr type(1), d01_attr_two_decl line(2) and
  d02_attr_two_attrs line(2), all -> EQUAL; r11u107repro/grid/t13_iface_tp_struct fullname(13) -> fullname(11),
  r11u18repro/t4 line(6) -> line(2)); surelog default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2,
  regressions = conversions = changes = 0 on all three binaries, the surelog csvs differing only in the LowMemLib
  testflags detail text (the workdir path); uhdm2rtlil 803 / 1 / 67 in both modes, csvs identical; downstream 803
  IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the three csvs byte-identical and equal (sorted) to
  results/downstream_uhdm2rtlil.csv. Every sweep exited 1 on the law-index check alone.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors from
  `drivers/bvmirror.sh`, 3365 databases mirrored and the 8 fenced row-mode databases left out unread;
  `evidence/byteverify_corpus_PL.txt`, `evidence/byteverify_corpus_fix.txt`): law vs pristine 0 / 952 surelog,
  0 / 1608 uhdm2rtlil, 0 / 805 downstream (SELFCHECK 951, 1607, 804 flagged); fix vs law and fix vs pristine the same
  zeros. Probe (md5 of every probe database; the pristine probe stage rerun from the law worktree because a probe
  database embeds its worktree's path, a first cross-worktree comparison flagging 1763 path-only differences): law vs
  pristine **15 of 4087**, exactly the implementer's frozen prediction (`evidence/byteverify_probe_PL.txt`); fix vs law
  0 of 4087.
- **Away census on the 15 probe movers** (`drivers/probeaway.sh`, order-blind `away.py` and chain-keyed
  `awaychain.py` with the variant comparator strictcmp_x built by `drivers/cc_x.sh`; positive control: the binaries
  swapped on VI/vi01 read chain away 8): chain away 0 on all 15, order-blind lost 0 on 14, t13 lost 2 (dist 10 -> 11,
  chain toward 2), the implementer's residue 2.
- **The implementer's grid** (39 dirs, 78 case-views, rerun by `drivers/vgrid.sh` into `evidence/impl_grid.txt`): 624
  lines identical to `r11u281repro/evidence/grid.txt` in every cmp, cmplines, strict and rc field with the same
  mover set; 64 moving, 56 entering STRICT_EQUAL, 0 leaving, 3 uhdm-cmp line changes (i07_el 83 -> 0, i08 22 lines
  shorter in both views), OFF == pristine on 78 of 78; the attribution identical (TPPATNEST alone 24, IFTPSHARE alone
  4, TPREBINDSPAN alone 2, TPPORTSPAN alone 2, the pairs IFTPSHARE + IFTPUSE 18 and TPREBINDSPAN + TPPORTSPAN 14); the
  fix moves none of the 78.
- **Byte controls** (`drivers/vcontrols.sh`, the implementer's 28 repro dirs, 1128 dirs after the fence filter, 2256
  case-views on pristine, law and fix; `evidence/controls.txt`, `evidence/controls_summary.txt`): pristine -> law 22
  moving, 1 entering (v11u275repro VN/vn11 default view), 0 leaving, 0 exit-code or uhdm-cmp line-count changes, the
  same 22 movers by name; pristine -> fix the same; law -> fix 0. Away census on the 22
  (`evidence/controls_away.txt`): chain away 0 on all 22, order-blind lost 2 on r11u273repro TP/t11_iface and
  v11u273repro VT/vt07_iface_tp in both views (t13's face). 34 case-views fail (SURELOG_FAIL, or exit 3) identically
  on all three binaries.
- **Firing census of the fix** (`drivers/fixcensus.sh`, frozen as `evidence/predict_fix.txt` before the fix sweep):
  6 lines, all probe, all `PATNAMED281V_ABSTAIN` (r11u108repro f5a10_writtendims_ctl and f5a11_unpacked_ctl,
  r11u110repro f2 i06_unpacked_2state and i08_unpacked_2dim, v11u108repro b25_attr_wdims, v11u110repro
  c05_unpacked_top_default), `MULTIDECL281V` firing nowhere in the probe or the corpora. The abstention sits before
  pass 275's "no override reached the element" return, so it over-predicts: on these 6 the law wrote nothing either
  (no `TPPATNEST` line in the implementer's census) and none moved: fix vs law 0 of 4087 probe and 0 of 3365 corpus
  databases.
- **Canaries** on all three sweeps: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS with
  EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6.
- **Binary-path audit** (cmds.txt path list fence-filtered first): 3265 of 3315 name each sweep's own frozen binary on
  pristine, law and fix; the other 50 carry no slang line; none names another binary.
- **Determinism** (`drivers/det.sh`, three concurrent draws per row-mode; `evidence/determinism.txt`): Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes, the 12 row-modes that write a
  database one hash each on the law and on the fix, equal to the implementer's and to the P, L and F sweeps' hashes.

## The attack grid (cases/, 82 dirs, both views, every line with its exit code)

`drivers/vgrid.sh` runs each case on pristine (P), law (L), law + R11U281_OFF (OFF), each law switch on the law, the
fix (FIX), fix + R11V281_OFF (FIXV), fix + R11U281_OFF (FIXU) and each refinement switch on the fix
(`evidence/grid.txt`, 2132 lines; `drivers/gsum.py` -> `evidence/grid_summary.txt`). Every case's first line names its
law. Goldens from Surelog v1.87 with check_probe's arguments (`drivers/case.sh`, cache keyed by the case's content).

- **164 case-views, exit code 0 on all, OFF == P, FIXU == P and FIXV == L on 164 of 164.**
- Pristine -> law: 150 moving, 80 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 11 uhdm-cmp line changes all
  shrinking (vi01, vi02, vi03, vi10, vi18, vi19, vi31 elaborated 33 -> 0, vi11_el 83 -> 0, vi40_el 215 -> 0, vi25
  1222 -> 1200 and 1502 -> 1480 still stage 1). Attribution: IFTPSHARE + IFTPUSE together 74, TPPATNEST alone 36,
  TPREBINDSPAN + TPPORTSPAN together 22, IFTPSHARE alone 10, TPPORTSPAN alone 6, and the three span-and-array laws
  together on 2. Chain-keyed away (`evidence/grid_away_PL.txt`): **8** (vn08, vn14, vn15, vn16, both views).
- Pristine -> fix: 142 moving, 86 entering, 0 leaving, the same 11 shrinking line changes; chain-keyed away 0 on all
  142 (`evidence/grid_away_PFIX.txt`), order-blind lost 2 on vi41 only (t13's face). Law -> fix: 18 movers, each back
  to the law's bytes under exactly one refinement switch (MULTIDECL 10, PATNAMED 8).
- Downstream (`drivers/dscases.py`, `evidence/downstream_cases_{P,L,FIX}.txt`, `evidence/downstream_cases_summary.txt`):
  pristine 39 IDENTICAL, law 59, fix 65; pristine -> fix: 22 DIVERGENT -> IDENTICAL, 3 DIVERGENT -> EQUIVALENT, 4
  EQUIVALENT -> IDENTICAL, 53 unchanged, none worse.

Families:
- **VI** (law 4 and law 5, 42 dirs): value-parameter-dependent defaults `T = logic [W-1:0]` with W overridden by name
  (vi01), in order (vi02), by defparam (vi19), passed from a parent (vi18, vi31) and a localparam type (vi10), all
  STRICT_EQUAL and IDENTICAL downstream with the law: golden binds the definition's default object whatever W is, and
  uhdm2rtlil sizes both lanes the same; package and $unit typedef, int, signed, scalar, union and struct defaults;
  packed and unpacked dimensions on the signal; var and wire; macro-written and CRLF declarations; modport consumers;
  generate-loop instances; interface arrays with an ordered override (vi39); a named override of another parameter
  (vi09, vi40, vi42); multi-declarator declarations (vi28, vi34, vi36, vi37, vi38: the second break).
- **VN** (law 1, 20 dirs): two instances with different overrides, a default then an override, mixed declarations,
  parameter-sized unpacked depth, extra packed dims on a port, two declarators on a line, nested instances, always_ff
  drivers, a struct element, two files with the same declarator position (included headers), generate loops, a
  macro-defined module pair, a 2-D unpacked net, an instance overriding rt_t itself, and the ordered overrides (vn08,
  vn13 to vn17: the first break).
- **VR** (laws 2 and 3, 20 dirs): instance arrays, named-same then ordered-different and the reverse, a package
  typedef, an override from an included header, a parent's default passed through, two levels, a multi-line override,
  a signed element, CRLF, a bind, extra packed dims on the port, a typedef alias, an if-generate, two named instances
  then a default, an output port, an instance with a body net, a parent's named override with the child ordered
  (vr13, golden following it) or unnamed (vr14).

## Residues (ranked; all wrong on pristine too, none moving away under the fix)

1. The interface struct type parameter after `assign u.d = ...` (r11u107repro t13, r11u273repro TP/t11_iface,
   v11u273repro VT/vt07_iface_tp, fresh VI/vi41): law 4 lists the definition's struct (parented at T, members
   `work@ifc.T.a`) where pristine listed a copy whose members happened to read `a`; order-blind lost 2, chain-keyed
   toward 2, the strict count shrinking. The implementer's residue 2 (§ typeParamStructLastNetParent273 extended to a
   hier_path left side), confirmed, not attempted here.
2. Interface signals law 5 does not reach: `T [1:0] d` (vi06) and `T d [2]` (vi07) stage 1, a signal in an interface
   generate block (vi21, line, DIVERGENT on every binary), a typedef of T inside the interface (vi23, stage 1,
   DIVERGENT), an interface port typed T (vi30, col, DIVERGENT), a var initializer (vi29, endcol), two instances with
   two declarators (vi38, fullname; IDENTICAL downstream with the fix), an ordered struct override (vi32, stage 1,
   DIVERGENT), a named override beside a default instance (vi17) and a second type parameter named (vi42), stage 1
   and DIVERGENT on every binary (the named instance's own copy), an interface instantiated in an interface (vi25).
3. Law 1's open shapes: mixed declarations and an extra packed port (vn03, vn05: line -> fullname, chain toward, vn05
   DIVERGENT -> IDENTICAL), a struct element (vn10, stage 1); every ordered type override (vn08, vn13, vn16: stage 1
   and DIVERGENT downstream on every binary, Surelog ignoring the ordered type override).
4. Laws 2 and 3: a parent's default passed through (vr06) and a bind (vr12) unmoved at line; vr07, vr09 (an unpacked
   body net: line -> endline), vr14 and vr15 (an extra packed port dim: line -> fullname) moving toward golden;
   ordered overrides (vr02, vr03), a package typedef (vr04) and a typedef alias (vr16) stage 1 on every binary.
5. The implementer's residues 1, 3, 4, 5 and 6 and the sister-ground faces stand as reported in
   tools/probe/r11u281repro/README.md.

## Process

- Worktrees /tmp/wt_v11u281 (law, then fix) and /tmp/wt_v11u281pris (pristine), both at aa8941fd; scratch under
  /tmp/v11u281_*; binaries frozen (`chmod a-w`) under /tmp/v11u281_bin before any measurement: pristine, law, fix1
  (b2b92892, the PATNAMED refinement alone, superseded before any gate measurement by the MULTIDECL one) and fix
  (e0aeb5ac). The law worktree's build dir was rebuilt for the fix while the law sweep ran from the frozen copy; the
  sweep's uhdm-strictcmp (fa6e4f42) did not relink.
- The verifier's SLIP: the first away census ran awaychain.py with the standard comparator in place of strictcmp_x,
  read 0 / 0 everywhere and cached those empty records under its scratch; the cache was deleted, the variant
  comparator built, the census rerun, and the positive control (binaries swapped on vi01, chain away 8) added. No
  number from the first run is reported.
- The fence: FENCED read from tools/probe/r11u107repro/canaudit.sh by drivers/env.sh, fail-closed; every corpus path
  list (mirrors, cmds.txt audit, census filter) filtered by word boundary before any file was opened; no fenced
  source or database read or dispatched outside the gate sweeps; determinism on a fixed list checked against FENCED.
  No process of another agent signalled or listed; every tool variable guarded with `[ -x ]`. Nothing written to the
  main tree.
