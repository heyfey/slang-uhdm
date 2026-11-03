# v11u470 — adversarial verification of r11u470 (module/type ground, pass 470)

Verdict: CONFIRMED, no break, no production change. The verified patch's src diff is
byte-identical to the implementer's (/tmp/r11u470.patch, md5 44170724faf8e7f267f844aca458c4b4).
Two attribution findings (below), neither a break.

Base e8a5bf18e, worktree /tmp/wt_v11u470. Binaries frozen in /tmp/v11u470_bin:
pristine = copy of the implementer's frozen pristine, md5 a6a6254bae1a79e2c4d36d6fecb0de6a
(the base build's md5); law = rebuilt once from the patch, md5 22eb28bc9ffef4bed8a34068c3be4e26,
equal to the implementer's law8, linking slang 12.0.0+545f88b2e.

## Source audit
src/UhdmExporter.cpp only. Four lawOn(470, ...) switches (R11U470_SPECVALARG_OFF,
R11U470_PKGTDPAIR_OFF, R11U470_TDSPECARGTD_OFF, R11U470_PROPFULLLAZY_OFF), six lawTrace(470, ...)
calls, no src/R*.h, no getenv, no new include, side lists only (a membership set and two pair
vectors cleared after use). storedFullName470 clears and restores a type_parameter's name and
parent so UHDM's generated getter computes an empty name and stores nothing: checked against
bytes below (17 + 4 dirs, law = pristine with R11U468_PROPSPECFULL_OFF).

## Gates (ONE five-stage sweep on law, /tmp/v11u470_sw, R11U470_TRACE on; evidence/sweep_*.log)
- probe EQUAL 4024 + STRICT_NOTEQUAL 63, regressions 0 conversions 0 changes 0; all 4087 probe
  databases the same as the control /tmp/intr11u468 by path-normalized uhdm-dump (negative control:
  200 of 200 shifted pairs DIFF).
- surelog 480 + 0 / 474 + 0, 0/0/0; uhdm2rtlil 803/1/67 both modes, 0/0/0; every non-detail column
  of the surelog, uhdm2rtlil and probe csvs equal to the control's.
- downstream IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, verdict diff 0.
- sv-tests EQUAL 1935, STRICT_NOTEQUAL 0, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, regressions 0 conversions 0 changes 0; the csv equal
  to the control's. Run through the main tree's tests/sweep.sh --corpus svtests (the worktree's
  UVM folder is empty; scripts/ and results/ unchanged between e8a5bf18e and the main HEAD).
- Both commands exit 1 on the law index alone (stale from this folder's new case files).
- Trace: no 470 firing in probe, surelog, uhdm2rtlil or downstream; sv-tests firings exactly the
  implementer's (param_vif_config_db: tdSpecArgTypedefShares470 7, specValueArgRefObj470 4,
  pkgTdSpecPairsImported470 2; the three scoreboard testbench rows and easyUVM:
  clsPropSpecFullNameLazy470 1 and tdSpecArgTypedefShares470 1 each).
- byteverify (SELFCHECK=1) against /tmp/intr11u468: surelog 1 of 962 (Scoreboard default),
  uhdm2rtlil 0 of 1608, downstream 0 of 805.
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil); ctcan2 PASS (EXPECT_UNKNOWN=1: ok=58;
  EXPECT_UNKNOWN=6: ok=2).
- binary audit: surelog 1531 of 1581 cmds.txt name /tmp/v11u470_bin/law (the rest hold only a
  Surelog line), uhdm2rtlil 1742 of 1742, sv-tests 2346 of 2346, no other binary named.
- determinism: MiniAmiq default, three concurrent draws plus the sweep, one hash in 4 of 4.

Targeted rows (kept pair against the cached golden): uvm_param_vif_config_db uhdm-cmp
230 -> 172, still DIFFERENT, head now golden's interface_typespec
tb_params_pkg::SFR_master_bfm_t (54:17) in the definition-view package listing (ParamEmit's
package typedef loop, the sister's ground, as reported); easyUVM 60 -> 60; the three scoreboard
rows EQUAL.

## FINDING 1 (attribution, not a break): the "Scoreboard default coin" is this pass's lazy law
Scoreboard default's bytes are deterministic per binary (evidence/scoreboard_default_draws.txt,
two draws each): pristine 10e9737f187d, law aba237436221, law + R11U470_OFF 10e9737f187d,
law + R11U470_PROPFULLLAZY_OFF 10e9737f187d, law + R11U468_PROPSPECFULL_OFF aba237436221,
pristine + R11U468_PROPSPECFULL_OFF aba237436221; three law sweeps (the implementer's law7 and law8
and this one) read aba237436221, the controls of passes 468 and 475 10e9737f187d; the uhdm-dumps
of pristine and law are identical. So the byte move pass 468 recorded as the Scoreboard coin is
§ clsPropSpecTpFullName468's getter store, and § clsPropSpecFullNameLazy470 removes it (the law
fires nowhere on that row, so it writes no trace line): a predictable mover the implementer
attributed to the coin with "no pass-470 law firing". The master should expect aba237436221 on
Scoreboard default from now on.

## FINDING 2 (unpredicted away mover, not a break)
Away census over the 1840 fence-filtered earlier case dirs under tools/probe whose sources hold a
class and a `#` (evidence/away_census_specdirs.txt): no exit code moves, 1822 byte-identical,
18 move: the 17 dirs of v11u468's finding (r11u254 I/i10_copy, r11u434 SF/sf04 to sf07,
v11u434 VS/vs01 to vs12; each law = pristine + R11U468_PROPSPECFULL_OFF, 17 of 17, verdicts kept:
16 STRICT_EQUAL, vs11 NOT_EQUAL 33 lines) and r11u269 U/u07_macro_utils, moved by
§ tdSpecArgTypedefShares470 alone (R11U470_TDSPECARGTD_OFF restores pristine's bytes): the
pc::type_id argument `this_type` shares the typedef's own object; uhdm-dump identical, dump
distance 46 -> 46, STRICT_EQUAL 78 objects on both, STRICT_EQUAL 75 under --no-canon on both.
Typespec identity only. The implementer's away census covered the 17 dirs and did not name it.

## Implementer's grid reproduced (evidence/impl_grid_*.txt)
32 dirs: exit code, uhdm-cmp count and strict verdict equal to the implementer's law8 and pristine
grids on every dir (va16 rc 3 on both, the negative control); STRICT_EQUAL 7 -> 10;
R11U470_OFF gives pristine's md5 on 32 of 32.

## Attack grid (cases/VK, VT, VP, VL; 36 dirs; evidence/grid_*.txt)
Every case accepted by upstream slang except VK/vk04 (a parameterized class name without
arguments, slang rc 1, ours rc 3 on both binaries: the negative control). Every other exit code
0 on both binaries (35 runnable dirs; grid_*.txt hold them, vk04 recorded in the first run). R11U470_OFF gives pristine's md5 on all 35; each switch alone
restores exactly its own movers (SPECVALARG: vk01 vk03 vk05 vk08 vk09 vk11 vk12 vk13 vt01;
PKGTDPAIR: vp01 vp05 (and vk13, vp03 together with SPECVALARG); TDSPECARGTD: vt02 vt03 vt04
vt06 vt08 vt10 vt11 vt12 vt13 vt14; PROPFULLLAZY: none, its byte face checked on the 17 away dirs).
STRICT_EQUAL 5 on pristine -> 12 on law (vk01, vk03, vk11, vk12, vk13 and VT/vt03, vt11 newly);
vk09 NOT_EQUAL -> STRICT_NOTEQUAL fullname; vt12 NOT_EQUAL -> STRICT_NOTEQUAL name.
No dir further from golden: dump distance (drivers/dist.sh) on every mover lower
(vk01 50->0, vk03 49->8, vk05 78->37, vk08 53->4, vk09 105->14, vk11 98->8, vk12 49->8,
vk13 151->98, vp01 318->314, vp03 299->192, vp05 240->236, vt01 74->25, vt02 18->12, vt03 14->8,
vt04 55->49, vt06 32->16, vt08 18->12, vt10 18->12, vt11 63->14, vt12 63->22, vt13 195->144,
vt14 203->152). The rises in uhdm-cmp lines (vk05 87->254, vp03 244->383, vt02/vt06/vt08/vt10
36->145..209) are later heads printing larger subtrees, as the implementer's ts03.
Downstream (ds.one, both binaries) on vk01, vk03, vk05, vk09, vk11, vk13, vp01, vp03, vt02,
vt03, vt06, vt10: IDENTICAL on both (no gates: class-only designs).

Cases and laws:
- § specValueArgRefObj470: VK/vk01 class property, vk02 module variable, vk03 class name a
  typedef of a specialization, vk04 negative control, vk05 class enum constant K::E (golden
  writes the K::E unsupported_typespec; the class-local enum listing is an older face), vk06
  typedef inside a class, vk07 $unit, vk08 type formal first, vk09 two typedefs, vk10
  module-local class and typedef, vk11 untyped formals (the sv-tests shape), vk12 typedef also a
  class property, vk13 target importing a parameter package; VT/vt01.
- § pkgTdSpecPairsImported470: VP/vp01 type arguments, vp02 literal values, vp03 type then K::d,
  vp04 named arguments (left alone: emitClassPropSpecParams163 returns on a named argument),
  vp05 three formals two written.
- § tdSpecArgTypedefShares470: VT/vt02 two specializations, vt03 $unit, vt04 module-local, vt05
  typedef of another package's class (no clone, unchanged), vt06 two typedef arguments, vt07 a
  package logic typedef argument (not taken, unchanged), vt08 class property, vt09 struct typedef
  (unchanged), vt10 plain and specialized, vt11 nested class, vt12 foreign class with clones,
  vt13 typedef of a typedef, vt14 two clone packages.
- § clsPropSpecFullNameLazy470: VL/vl01 to vl04 (byte-identical on both binaries; vl01 is a
  matched case, both laws tracing).

## Residues (all wrong on pristine too, none moved away)
1. uvm_param_vif_config_db: the package virtual-interface typedef listing (ParamEmit, sister).
2. § specValueArgRefObj470 not reached at a module variable (VK/vk02), a class-scope typedef
   (vk06), $unit (vk07) and a module-local typedef (vk10): golden writes the K::w
   unsupported_typespec at each; the law writes only through emitClassPropSpecParams163.
3. § tdSpecArgTypedefShares470: the copied alias's target in another package (VT/vt14, ts01:
   golden aliases t::cfg_t, uhdm-cmp 17 lines), a foreign-class this_t named D where golden shares
   a::this_t (vt12, STRICT_NOTEQUAL name), a non-class package typedef argument golden copies
   (vt07), module-local classes listing type_id parameters golden omits (vt04).
4. § pkgTdSpecPairsImported470: the importing package's import-copy listing heads (vp01, vp02,
   vp04, unchanged).
5. easyUVM and the implementer's carried lists.

## Process
One law build, one five-stage sweep, no pristine build or sweep (the pristine reading the master's
control /tmp/intr11u468). The sweep was launched after quietwait.py read the machine quiet. The fence
list was read into a file by a program without printing; every tree-wide list was filtered on it
before any file was opened; this folder scanned clean. No other agent's process touched.
Drivers: drivers/runcase.sh, dist.sh, env.sh, away.sh, quietwait.py.
