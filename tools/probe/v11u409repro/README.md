# v11u409: adversarial verification of r11u409

The expression/parameter ground, pass 409. The verifier rebuilt the law binary from /tmp/r11u409.patch on a fresh worktree at 09e0c3a9. It ran the five-stage gate on that binary and attacked the six laws with 48 fresh case dirs. It found one break: on legal SV, pristine wrote STRICT_EQUAL and the law wrote STRICT_NOTEQUAL. It also found one face that the law moved away from golden. Both are fixed by two refinements in src/ParamEmit.cpp, inside § modImpTdParamTsClone409. A second five-stage gate ran on the verified binary.

## Binaries

| binary | md5 | note |
|---|---|---|
| pristine | 03558f16f8e60eb82098892f0ba8d17d | the implementer's frozen copy, equal to the main tree's build at the base; the main tree's build/slang-uhdm is now pass 410's (90a46366...) |
| law | bf7324a61d231ac1c7cbdeabf71aa4d9 | rebuilt here once, equal to the implementer's /tmp/r11u409_bin/law.bin |
| verified | 53be25c652d262bd4033f25ee3c1677c | law + the two refinements below |

## Refinements (fixOn(409, ...), R11V409_OFF gives the law's bytes on 119 of 119 case dirs)

- § tdCloneNoPrefixAbstain409v (R11V409_TDNOPREFIX_OFF, ParamEmit makeParamTs inside § modImpTdParamTsClone409). **This is the break.** Take a module parameter typed by a `$unit` typedef of `int`: `typedef int i_t; module sub #(parameter i_t N = 2)`. makeParamTs is also called with no ref prefix for the elaborated copy. There the law minted a fresh clone whose Typedef_alias ref is named by the bare typedef `i_t`, where golden writes `work@top.u.i_t` (or `work@top.i_t`). Pristine reads STRICT_EQUAL on three cases (VI/vi03, vi16 and vi18); the law reads STRICT_NOTEQUAL fullname on all three. The refinement abstains when the prefix is empty and the typedef is not homed in a package. The verified binary reads STRICT_EQUAL on all three: vi16 has pristine's bytes, and vi03 and vi18 are new bytes that are closer to golden. vi09, a generate-block localparam typed by a module typedef, goes back to pristine's bytes: the law had cmp 70 and 213 dump lines away, pristine has cmp 14 and 261. A typedef homed in a package keeps the law's output: VI/vi06 is judge-equal under the law and stays judge-equal.
- § tdCloneQualNameAbstain409v (R11V409_TDQUAL_OFF, same site). Take a MODULE parameter written with a qualified 2-state typedef, `parameter p::ft_t W` with `typedef bit [3:0] ft_t` in p. Golden shares the package's typedef object `bit_typespec (p::ft_t)`, with no clone and no alias, as the logic branch's § pkgTdQualParam111 family does. The law minted a clone named `ft_t` aliased `work@top.W.ft_t`. That moved the dump away from golden: 36 -> 54 lines, uhdm-cmp 66 -> 126 lines, on VI/vi02 (a parameter port) and vi14 (a body parameter). The verified binary has pristine's bytes on both. The logic twin of vi02 was STRICT_EQUAL on pristine, on the law and on the verified binary.
- Neither refinement moves any of the implementer's 71 grid case dirs (byte-identical law vs verified). Each refinement's own switch restores the law's bytes on the cases it moves.

## Reproduction of the implementer's numbers

All numbers below are from the law binary bf7324a6.

- **Law build:** md5 equal to the implementer's.
- **Implementer's grid:** all 71 lines reproduced (rc, cmp lines and strict status per case). R11U409_OFF restores pristine's bytes and exit code on 71 of 71.
- **Full five-stage sweep (/tmp/v11u409_lwd)**, the corpus stages from this worktree and sv-tests through the main tree's scripts/check_svtests.py read-only against this base's results/golden_svtests.csv:
  - probe: EQUAL 4018, STRICT_NOTEQUAL 69, 0/0/0; the csv is byte-identical to the golden and to the control.
  - surelog: 480 + 474 CMP_EQUAL, 0/0/0; the csv differs from the control only in the two LowMem log-path texts.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0; the csv is identical to the control.
  - downstream: 803/66/2/0, csv identical to the control.
  - sv-tests: regressions 0, conversions 77, changes 8. Totals EQUAL 1646, STRICT_NOTEQUAL 95, DIFFERENT 199, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1. The csv is identical to the implementer's on all 2346 rows, and the CONVERSION/CHANGE list is line-identical (evidence/svtests_moves_law.txt).
- **byteverify against the control /tmp/intr11u407:** 0 of 962, 0 of 1608, 0 of 805 movers; the selfcheck flags 961, 1607 and 804.
- **Canaries:** ok=52 and ok=16; both ctcan2 checks pass.
- **Binary audit:** 3313 fence-filtered cmds.txt. 3263 name the law binary, 0 name another binary, 50 have no slang-uhdm line (two of them, the CoresSweRV rows, mention the UVM path only).
- **The four-law claim on uvm_agent_class_0**, one runner call per switch: each of R11U409_TDPARAMCLONE_OFF, _DEFIMPARITH_OFF, _IMPENUMSIZE_OFF and _OOBEVTRIG_OFF alone reads NOTEQUAL/DIFFERENT. R11U409_STREAMPAREN_OFF reads JUDGE_EQUAL at col(4). All five switches on reads JUDGE_EQUAL at col(2).

## The verified binary's gate (/tmp/v11u409_vwd)

The full five-stage sweep ran once, on a quiet machine:

- **Stage results:**
  - probe: 4018 + 69, 0/0/0; the csv equals the golden.
  - surelog: 480 + 474, 0/0/0.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
  - downstream: 803/66/2/0, csv identical to the control.
  - sv-tests: 0 / 77 / 8, with the csv identical to the law sweep's on all 2346 rows. Neither refinement fires on any sv-tests row: the law's trace logs no empty-prefix firing, and no row changes.
- **byteverify, verified against law:** 0 of 962, 0 of 1608, 0 of 805.
- **Canaries:** ok=52 and ok=16; both ctcan2 checks pass.
- **Binary audit:** 3263 of 3313 name the verified binary, 0 another, 50 with no slang line.
- **Away census on sv-tests:** verified against the control on the 315 kept databases both sweeps share (evidence/away_linediff.txt). The ordered dump-diff count read 124 toward golden and 136 at the same distance (the line-diff normaliser leaves a path line, so every row reads MOVED). It read 8 AWAY, all large UVM rows (18.5.11 static-constraint-blocks_1, uvm_ac_config_db, uvm_generation_seq_persistence/poly/randomization, uvm_id_register, uvm_messaging_example, uvm_overriding). By the implementer's line-multiset distance (away.py), all 8 move TOWARD golden: for example uvm_id_register 486015 -> 422225 (evidence/away_multiset_8rows.tsv). The ordered count is inflated by object order. **0 away.**

## Attack grid: 50 fresh case dirs

The groups are VG (gate genvar fold), VI (typedef parameter clone), VN (enum import size), VO (out-of-body event trigger), VS (stream paren in macro) and VW (definition-view import arithmetic size). Every case's first line names its law. The full table is in evidence/grid.txt plus evidence/grid_extra.txt. Each line gives the pristine, law and verified readings, plus three switch checks: R11U409_OFF on law gives pristine, R11V409_OFF on verified gives law, R11U409_OFF on verified gives pristine. All three switch checks hold on 119 of 119 case dirs (the implementer's 71 plus 48 of these); vi19 and vi20 were added later and measured on the three binaries.

**Verified against pristine, 48 grid cases:**
- 7 cases go NOT_EQUAL -> STRICT_EQUAL: VG/vg01, vg02, vg05, vg06, VO/vo01, vo07 and VI/vi15.
- VS/vs04 goes STRICT_NOTEQUAL (col) -> STRICT_EQUAL.
- VI/vi06 goes NOT_EQUAL -> STRICT_NOTEQUAL (fullname).
- 20 cases stay NOT_EQUAL and move toward golden.
- 12 cases stay NOT_EQUAL with pristine's bytes.
- 5 STRICT_EQUAL controls keep pristine's bytes.
- 2 STRICT_EQUAL cases stay STRICT_EQUAL with new bytes closer to golden: vi03 and vi18.
- None moves away, none leaves an equal status, and no exit code changes.

**Under the law alone** (before the refinements), three cases left STRICT_EQUAL (vi03, vi16, vi18) and two moved away (vi02, vi14).

**Downstream verdicts** (evidence/downstream_cases.txt) on the 48 cases and the implementer's 9 GV cases: the same verdict on pristine, law and verified for every case. 52 are IDENTICAL. VI/vi13, VW/vw04 and vw06 are EQUIVALENT on all three, and VN/vn03 and VW/vw02 are DIVERGENT on all three.

### Cases per law

- **§ genGateTermGenvarFold409**
  - Converted: VG/vg01 (`i-1` in a gate terminal), vg02 (nested genvars, `2*i+j`), vg05 (udp, `3-i`), vg06 (`generate` region with a gate outside).
  - Toward golden, still NOT_EQUAL: vg03 (`a[i/2]`: golden folds a `/` to INT, the law abstains) and vg04 (`y[i<<1]`, a bufif1 and a tran: golden folds `<<` to UINT, the law abstains).
- **§ modImpTdParamTsClone409**
  - Converted: VI/vi15 (a `$unit` bit-vector typedef parameter with an instance override).
  - Toward golden, still NOT_EQUAL: vi01 (a module's own localparam: the elaborated param_assign constant's clone is missing; the cmp head is later in the walk), vi05 (signed), vi08 (an interface), vi11 (byte and scalar bit), vi12 (an import chain through a second package), vi17 (a qualified type in a package parameter).
  - Judge-equal, STRICT_NOTEQUAL: vi06 (a package `int unsigned` typedef, a module-scoped import; the alias ref in the elaborated copy is named `u_t` where golden writes `work@top.u_t`, the empty-prefix site).
  - Abstaining with pristine's bytes: vi04 (an alias of an alias), vi07 (shortint/longint), vi10 (a class parameter), vi13 (integer, an unpacked parameter).
  - Controls: vi19 (the logic twin of vi02: STRICT_EQUAL on all three) and vi20 (`typedef bit [7:0]` at `$unit` with an override: pristine NOT_EQUAL 200 dump lines, law STRICT_NOTEQUAL fullname, verified NOT_EQUAL 132 lines; see residue 2).
- **§ tdCloneNoPrefixAbstain409v:** VI/vi03, vi09, vi16, vi18.
- **§ tdCloneQualNameAbstain409v:** VI/vi02, vi14, vi19.
- **§ defImpArithSize32_409:** VW/vw01 to vw07 (sized-literal sums, a 40-bit shift, a ternary, a negative difference, a mask over a bit parameter, a concatenation and a product, an interface import). Every case moves 2 to 4 dump lines toward golden (the size cell is now 32 as in golden) and stays NOT_EQUAL on other heads. Nothing moves away.
- **§ impEnumParamRefNoSize409**
  - Abstaining with the same bytes: VN/vn01 and vn02 (`enum int` and `enum integer` bases).
  - Toward golden: vn04 (an alias of the enum typedef), vn05 (an interface import), vn06 (mixed: a logic-based enum abstains, a base-less localparam fires).
  - vn03 exits 4 on all three binaries; see residue 1.
- **§ oobEventTrigHoistNet409**
  - Converted: VO/vo01 (an event inherited from a base class) and vo07 (a static method and a static event).
  - Toward golden: vo05 (two events and a re-trigger).
  - Abstaining: vo02 (`-> this.e`, NOT_EQUAL on both), vo04 (a `$unit` class, STRICT_EQUAL on both), vo06 (an event argument).
  - Unchanged control: vo03 (a local event plus a module net of the same name, STRICT_EQUAL on both).
- **§ streamBraceParenMacro409**
  - VS/vs04 (`int'({ << bit { X }})` through a macro): STRICT_NOTEQUAL col -> STRICT_EQUAL.
  - Toward golden: vs01 (`>> byte`).
  - Unchanged: vs02 (no cast) and vs03 (double parentheses with a `<< 2` slice).

## Residues (ranked)

1. **Goal-1 face, this ground, wrong on every binary.** A base-less enum package parameter whose default is a cast, `parameter e_t P = e_t'(1)`, imported into a module, exits 4 with `expression kind: Invalid` (VN/vn03; /tmp/v11u409_scr/cs/g1 is the minimal form). Upstream slang accepts it ("Build succeeded: 0 errors"). The site is ParamEmit's import copy.
2. **The empty-prefix site of § modImpTdParamTsClone409.** Golden names that clone's alias ref with the importing instance's path: `work@top.u_t` (vi06), `work@top.u.i_t` (vi03), `work@top.i_t` (vi16). The law wrote the bare typedef name. The refinement keeps pristine's bytes for a non-package typedef. That costs the law's judge-equal gain on vi20 (a `$unit` `bit [7:0]` typedef, verified still 132 lines closer than pristine) and vi09's dump-line gain. Narrowing the refinement to the int_typespec kind (where pristine was right) would keep vi20, but it was not built: the budget allows no third build or sweep. Writing the instance-path prefix is the real fix.
3. The gate-fold operators the law does not reach: `/` (golden INT) and `<<` (golden UINT) on a genvar (vg03, vg04).
4. § modImpTdParamTsClone409 leftovers: the elaborated param_assign constant clone of a module's own localparam (vi01), generate-scope localparams (vi09), class parameters (vi10), shortint/longint/integer (vi07, vi13), and an alias of an alias (vi04).
5. `-> this.e` in an out-of-body method (vo02).
6. Everything in the implementer's residue list stands as written: the UVM col(2) `begin` column at uvm_object_defines.svh line 804 (UhdmExporter, the sister's file), the 67 UVM rows headed on the sister's ground, and the singletons.

## Sister-ground faces

None new. The implementer's list stands: the UhdmExporter macro column after a token paste, impTsCopy402's byte branch, `$unit` function order, package listing order, the TypeEmit `this` net order and class_typespec spans, and the class listing's extra out-of-body method under a `$unit` import.

## Process

- No pristine build and no pristine sweep: the pristine reading is the master's control /tmp/intr11u407. The law binary was built once and the verified binary once. Two intermediate refinement builds (/tmp/v11u409_scr/ver1 and ver2) were measured on case dirs only; ver2 is byte-identical to the frozen verified binary. Two five-stage sweeps ran, each on a quiet machine.
- **Slip:** six single-row runner calls on uvm_agent_class_0 (one per switch, 3 jobs) were started while the r11u412 pair's corpus sweep was live. My pgrep had shown its sweep and I did not wait. Neither of my sweeps overlapped another sweep.
- The fence list was read from canaudit.sh's FENCED= line into a file without printing. One masked structural view of tests/FENCED.md was printed, with every letter and digit replaced by x. Every tree-wide reader filtered on the list. No fenced test was named, opened or run.
- No other agent's process was touched. Two of my own wait loops were stopped by task id: one pgrep-count loop that could match its own command line, and one superseded loop.
