# r11v145 — adversarial verification of r11u145 (expression/parameter ground, strict axis)

Base `c24699f1` (branch matrix-1.87). Implementer's patch `/tmp/r11u145.patch` (md5 `fa578b0595c5d7b84ceab557f0411ebf`),
applied clean to a fresh worktree `/tmp/wt_v11u145`; pristine worktree `/tmp/wt_v11u145pris`. System-deps config,
`-j 2`. Every binary was frozen (`chmod 555` copies under `/tmp/v11u145_bin`) before it measured anything. Every
`cmds.txt` of the pristine, law and verified corpus sweeps names its own frozen binary (3273 of 3273 slang lines in
each; the other 50 of 3323 are Surelog-only rows). The downstream databases of the targeted rows are byte-identical to
the frozen binary's own run with the translated command line.

| binary | md5 |
|---|---|
| pristine (rebuild of the base, byte-identical to the main tree's `build/slang-uhdm` at `c24699f1`) | `a408021857111d030b0571aee87d105b` |
| law (r11u145 as delivered; reproduces the implementer's md5) | `5a327fb1484f60c446cc2d06c5cf3584` |
| verified (law + § lpBoundOperandKeepsBase145v) | `33be614213a21110c065b57593dec57e` |
| `build/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` |

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of the implementer reproduces bit for bit. One law,
§ lpPaCopyBoundOwnerName145, is broken on legal SV. When the part-select is an operand (`a[7:L] == B`, `a[7:L] & b`,
`~a[7:L]`, `{a[7:L], 4'h0}`, `c ? a[7:L] : 0`), golden keeps the select base's name on the copied bound's
ref_typespec, and the law moved it to the declaring instance. Nine fresh cases went from STRICT_EQUAL on pristine to
STRICT_NOTEQUAL on the law binary. The same fault moved 112 ref_typespec names in Rggen/default away from golden,
past that row's strict walk divergence (record #469), so the strict column could not see it. The refinement
§ lpBoundOperandKeepsBase145v (switch `R11V145_LPOPND_OFF`) restores the pristine bytes on all nine cases and on Rggen.
It moves no probe case and no uhdm2rtlil database, and no downstream row. The law and verified sweep csvs are
identical row for row (surelog modulo the workdir path in the LowMemLib detail text).

## 1. Reproduction (law binary against the committed baselines)

| stage | implementer | reproduced (evidence/sweep_L.txt) |
|---|---|---|
| probe | regressions=0 conversions=44 changes=4; EQUAL 2295 -> 2339 | same |
| surelog | regressions=0 conversions=2 changes=11; strict-equal 788 -> 790 | same (CMP_EQUAL 397+391 -> 398+392) |
| uhdm2rtlil | regressions=0 conversions=4 changes=26; strict-equal 1394 -> 1398 | same (697+697 -> 699+699) |
| pristine sweep | regressions=0 conversions=0 changes=0 in all three | same (evidence/sweep_P.txt) |
| the 91 CONVERSION/CHANGE lines | evidence/sweep_law_vs_baselines.txt | byte-identical list (evidence/changes_law_vs_baselines.txt) |
| byte movers vs pristine | surelog 27/960, uhdm2rtlil 32/1608, probe 53/4087 | same counts and the same names (path sets identical, selfcheck 959/960 and 1607/1608; probe databases compared from one checkout path) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, 0 of 871 changed | same (evidence/downstream_L.txt) |
| canaries | surelog ok=48 changed=4 (Scr1SvTests, BasicOh), uhdm2rtlil ok=16; ctcan2 PASS ok=58 / ok=2 | same (pristine: ok=52 changed=0) |
| switches | `R11U145_OFF=1` byte-identical to pristine on the grid; single switches move only their own grid | same on 159 cases (52 implementer + 107 verifier) |

Converted rows, fresh csv rows (results/ untouched):
`DefaultPatternInt,default,CMP_EQUAL,,,equal`, `DefaultPatternInt,testflags,CMP_EQUAL,,,equal`,
`ibex_counter,default,CMP_EQUAL,,,equal`, `ibex_counter,testflags,CMP_EQUAL,,,equal`,
`packed_struct_array_shift,default,CMP_EQUAL,,,equal`, `packed_struct_array_shift,testflags,CMP_EQUAL,,,equal`,
and 44 probe cases `EQUAL,,equal`. Targeted downstream rows (verified): `ibex_counter,IDENTICAL,OK,OK,129,129,,`,
`packed_struct_array_shift,IDENTICAL,OK,OK,54,54,,`, `comb_dyn_2d_packed_sel,IDENTICAL,OK,OK,124,124,,`.

## 2. Record-level check of every changed row-mode and every byte mover

* **The 91 changed pairs** (evidence/record_check_91_changed_pairs.txt, drivers/reccheck.py): for each pair, the
  strict per-object records (`--dump-a/--dump-b`) of golden vs pristine and golden vs law. Rule: no record differs
  under the law that did not differ under pristine before either walk diverges, and the divergence index never moves
  earlier. **91 / 91 OK.** Divergences are unchanged (comb_dyn #743/#653, ibex_pmp, qj27 #830, Scr1SvTests #16033,
  YosysBigSimEllip #70374) or removed (DefaultPatternInt).
* **The 59 corpus byte movers** (evidence/record_check_59_byte_movers.txt): the same rule, **59 / 59 OK**. YosysOldOpen
  (both modes) has identical records and a 0-line order-blind dump diff, so its only movers are serialized objects the
  walk never reaches.
* **Past the walk divergence** the strict walk is blind, so the whole order-blind uhdm-dump multiset was compared with
  golden's (drivers/obgold.py; evidence/orderblind_golden_distance*.txt). On every row but one the distance to golden
  shrinks: BlackBePipeInt -56, MiniAmiq -20/-12, Scoreboard -16,
  SeqDriver -212/-216, SimpleUVM -220/-216, Scr1SvTests -376, YosysBigSimEllip -776, Earlgrey_0_1 -516/-520,
  ibex_pmp -28, packed_struct_array_fifo -8, comb_dyn -4. The one exception is **Rggen/default: +224. The law removed
  112 lines that are in golden and added 112 that are not.** That is the break in section 3.

## 3. The break and its refinement

§ lpPaCopyBoundOwnerName145 (ExprEmit `emitExpr`, the § genCaLpPaCopy case) names the copied bound's ref_typespec by
the declaring instance whenever the constant is a part-select's bound. Golden does that only when the part-select is
the continuous assignment's whole right-hand side. The implementer's shapes are all that kind: ibex_counter
`unused_counter_load = counter_load[63:CounterWidth]`, lpb/l01 `o = a[L+3:L]`, and the fresh lpb/x01, x02, x04, x05,
x08, x16 and x17. When the part-select is an operand, golden keeps the select base, as pristine did.
Rggen rggen_address_decoder `i_address[WIDTH-1:LSB] == BEGIN_ADDRESS` names it
`...g_address_matcher.i_address`, and the law wrote `...u_decoder`.

| case (first line names the law) | pristine | law | verified |
|---|---|---|---|
| `lpb/x07_ps_in_compare` `a[7:L] == B` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname (`work@dut` vs golden `work@dut.g.a`) | STRICT_EQUAL |
| `lpb/x09_clog2_compare` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `lpb/x10_ps_in_and` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `lpb/x11_rggen_shape` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname (`work@dut` vs `work@dut.g_address_matcher.i_address`) | STRICT_EQUAL |
| `lpb/x12_ps_in_unary` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `lpb/x13_ps_in_concat` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `lpb/x14_ps_in_ternary` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `lpb/x18_left_bound_operand` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname | STRICT_EQUAL |
| `lpb/x19_two_ps_operands` (§ lpBoundOperandKeepsBase145v) | STRICT_EQUAL | STRICT_NOTEQUAL fullname (6) | STRICT_EQUAL |
| `lpb/x15_ips_in_compare` `a[L+:4] == 4'd3` (§ lpBoundOperandKeepsBase145v) | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname | pristine bytes (residue V2) |

**§ lpBoundOperandKeepsBase145v:** the copied bound takes the declaring instance's name only when the part-select's
own parent is not an operation. Site: ExprEmit.cpp `emitExpr`, the § lpPaCopyBoundOwnerName145 condition. Helper:
EmitHelpers.h `lpBoundOperandKeepsBase145v`. Switch: `R11V145_LPOPND_OFF`, which gives the law binary's bytes on
159 of 159 cases. `R11U145_OFF=1` on the verified binary gives the pristine bytes on 159 of 159.

Measured on the verified binary (evidence/sweep_V.txt, evidence/byteverify_verified_vs_law_*.txt,
evidence/downstream_V.txt):

* **Probe, surelog and uhdm2rtlil:** the same 91 CONVERSION/CHANGE lines as the law sweep, regressions=0 in all
  three. The csvs are identical to the law sweep's.
* **Bytes against the law sweep:** surelog 4/960, uhdm2rtlil 0/1608, probe 0/4087. The four surelog movers:
  * Rggen/default returns to pristine bytes. Its 224 order-blind lines are the 112 names.
  * SeqDriver default and testflags, and MiniAmiq/testflags, differ from the law sweep by 4 lines order-blind. That
    is the known UINT/vpiDecompile coin.
* **Bytes against pristine:** surelog 26/960, the law's 27 minus Rggen.
* **Downstream:** EQUIVALENT=2, IDENTICAL=803, SLANG_REJECT=66, and 0 of 871 rows changed on any column.
* **Canaries:** ok=48 changed=4 and ok=16. ctcan2 PASS ok=58 and ok=2.

## 4. Break grid: 107 fresh cases, every law x shapes and contexts (evidence/grid_159_cases.txt)

Every case was run through golden (Surelog v1.87, probe flags), pristine, law, verified, and every switch. All 795
runs returned rc=0, and no uhdm-cmp line count changed on any case. Transitions (pristine -> law -> verified): 49
STRICT_NOTEQUAL -> STRICT_EQUAL -> STRICT_EQUAL; 9 STRICT_EQUAL -> STRICT_NOTEQUAL -> STRICT_EQUAL (the break); 9
STRICT_EQUAL kept; 19 STRICT_NOTEQUAL kept (5 of them move, each to fewer differing objects or the same set); 21
stage 1 on all three.

| grid | law | cases | pristine -> verified |
|---|---|---|---|
| `dfi/` | § defaultFillImportCopies145 | x01 explicit import, x02 module-header import, x03 two parameterized instances, x04 a package importing the package, x05 local plus import (control), x06 struct element, x07 three int elements | x02 and x07 -> STRICT_EQUAL; the rest are stage 1 on both binaries |
| `usp/` | § unsignedScalarParamTsAtKeyword145 | x01 `logic unsigned` localparam, x02 overridden port parameter, x03 package parameter, x04 unpacked dimension, x05 `reg unsigned` in a generate, x06 `bit` without a sign (control), x07 interface parameter | x01, x02 and x05 -> equal; x03 -> decompile (the implementer's R5); x06 stays equal; x04 and x07 are stage 1 |
| `psb/` | § psBoundBareRefByBase145 | 27 shapes: always_comb, lhs part-select, port parameters, function and task (golden already equal), generate for/if, port connection, genvar bound, if condition, interface, class, member select, multi-dimensional, case item, modport, mixed bound, package and qualified bound, SVA, enum bound, left bound only, struct-parameter bound, genvar continuous assign, part-select inside an index, part-select of a parameter, part-select in a parameter init | 13 -> equal, 4 equal kept, x06 and x10 stage 1; x05, x11, x14, x17, x18, x20, x23 and x27 keep their pristine verdict (residue V4) |
| `uop/` | § unaryOperandParamOwnerName145 | `-M`, `!M`, nested generate, two overridden instances, interface, localparam, unary inside an index, concatenation, member and multi-dimensional lhs, generate-for, package parameter, a unary at the top level, a unary under a binary, no generate (control), generate else | 8 -> equal, x15 stays equal; x11 is the package-parameter residue V5; 6 stage 1 |
| `lpb/` | § lpPaCopyBoundOwnerName145 / § lpBoundOperandKeepsBase145v | indexed `+:`/`-:`, nested generate-for, parameterized instances, interface, `$clog2` localparam direct, lhs select, left bound, a generate-local control; the ten operand shapes in section 3 | direct: 7 -> equal, x06 stays equal, x03 stage 1; operand: 9 restored to pristine STRICT_EQUAL |
| `bso/` | § hpBaseSelOpIdxNamesByPath145 | rvalue, member bit-select, nested struct, variable index, ternary index, generate scope, unpacked array, function, `$clog2` index, generate definition view, class method, second-level op (control), unpacked 2-D, bit-select/call/member in the index op, interface array, NBA, port connection, `this.` in a class | 9 -> equal, x12 stays equal, x11 loses its fullname record (endcol left, sister ground); x06, x09, x14, x15, x16 keep their pristine verdict and x10, x17, x19, x20 are stage 1 (residue V3) |
| `iaw/` | § impElabArithWholeSpan145 | `S*2+1`, `>>`, explicit import, comparison, module-header import with a port list, parenthesized, child instance, cast init, qualified reference (control), untyped, `%` localparam | 7 -> equal, x09 stays equal, x04 stage 1; x06 and x08 keep the package-listing span (residue V6) |

Downstream verdicts (`ds.one`, both binaries) on 20 of the converting and break cases are all IDENTICAL.

Stage-1 movers (evidence/grid_stage1_dump_distance.txt) compare the uhdm-dump distance to golden and the uhdm-cmp
text with ids stripped. Every uhdm-cmp text is unchanged except where a ref name printed as context changed (bso/x19,
uop/x12). Distances are smaller or equal, except dfi/x03 (+14) and dfi/x06 (+8) (residue V1).

## 5. Mover attribution by switch (evidence/mover_switch_attribution.txt, evidence/uvm_orderblind_switch_attribution.txt)

Each of the 59 corpus byte movers was rebuilt with each single switch (drivers/attr.py):

| law | rows it moves (switch restores pristine bytes alone) |
|---|---|
| PSBAREREF | BasicOh, Scr1SvTests, YosysOldOpen (d/t), YosysBigSimEllip/d, comb_dyn_2d_packed_sel, mriscv_bind_sva, packed_struct_array_fifo (d/t), plus a share of Earlgrey_0_1 |
| IMPARITH | BlackBePipeInt, HierPathStructTypespec, ibex_alu/branch_predict/compressed_decoder/decoder/icache/multdiv_fast/multdiv_slow/pmp/tracer/wb_stage (d/t), plus shares of Earlgrey_0_1, SeqDriver and SimpleUVM |
| UNSPARAMTS | GenCase, GenCaseStmt, int_types (d/t) |
| DEFFILLIMP | DefaultPatternInt (d/t) |
| LPBOUNDOWN | ibex_counter (d/t), Rggen/default (the break) |
| BASESELOP | packed_struct_array_shift (d/t), Scoreboard/d, plus shares of MiniAmiq, SeqDriver, SimpleUVM and Earlgrey_0_1 |

Corrections to the implementer's report:

* **BasicOh.** The report attributes its -20 to PSBAREREF and UNARYOWN. `R11U145_UNARYOWN_OFF` leaves the law bytes
  on BasicOh, so the -20 is PSBAREREF alone. The lhs gate `caLhsIsSelect145` keeps UNARYOWN off BasicOh, and the
  predictor's `UNARYOWN 12` is an over-count.
* **The UVM family.** The report says it "did not move". In fact MiniAmiq, Scoreboard, SeqDriver and SimpleUVM
  (both modes) move by BASESELOP, and SeqDriver and SimpleUVM also by IMPARITH, by 16 to 236 order-blind lines
  beyond the 4-line coin. The moves fall past the walk divergence (record #2450 or so), so the strict cells are
  unchanged, and every one moves toward golden.
* **Earlgrey_0_1.** It moves by PSBAREREF (180 lines), BASESELOP (60) and IMPARITH (324), and not by LPBOUNDOWN,
  which the predictor also named.
* **Earlier passes' byte controls.** The implementer's set of 1663 cases left out r11u111, r11u113, r11u114, r11u116,
  r11u117, r11u137, r11u13, v11u111, v11u113 and v11u114. Over 2882 case directories under the r11/v11 grids
  (evidence/controls_earlier_passes.txt), 24 cases move:
  * r11u137 bt03/bt11 and r11v140 pfp/b11 and plv/v07 become STRICT_EQUAL.
  * r11v133 hpm/b10 goes from 3 to 2 differing objects.
  * 19 are stage 1 on both binaries, with the uhdm-cmp text unchanged and the dump distance to golden equal or
    smaller.
  * r11v124 pv/v14_string and qx/q08_string write no database on either binary, so they are not movers.
  * v11u112 brk2/k/m07_hdr_enum_default segfaults (rc=139) on both binaries. That is pre-existing.

## 6. Residues (ranked; decoded, not landed)

The implementer's R1-R10 stand. The verifier adds:

* **V1 (§ defaultFillImportCopies145 neighbourhood, stage 1).** Golden does not expand `'{default: X}` in dfi/x03
  (`logic [3:0]` elements, `4'hA`) or dfi/x06 (struct elements, `'0`). It keeps the operation with its
  tagged_pattern. Ours expands it (pre-existing), and the law now mints one copy per element, so the dump distance
  grows by 14 and 8. uhdm-cmp already fails on both binaries, so no strict cell is involved. Site: ParamEmit
  `emitParameters`, the default-fill expansion guard.
* **V2 (§ genCaLpPaCopy case).** For an indexed part-select operand (`a[L+:4] == 4'd3`, lpb/x15), golden names the
  bound's ref_typespec by the select (`work@dut.g.a`). Pristine and verified both name it by the scope
  (`work@dut.g`).
* **V3 (§ hpBaseSelOpIdxNamesByPath145 frontier).**
  * The generate definition-view copy keeps `work@dut.g.i` where golden has `work@dut.g.sd[i + 1].v.i` (bso/x06).
  * A system-call index `sd[$clog2(D)].v` gives golden `work@dut.sd[].v.D` (x09).
  * A part-select inside the index op gives golden `work@dut.sd[1:0 + 1].v.j`, ours `...v.sd.j` (x14).
  * A function-call argument inside the op gives golden `work@dut.sd[ + 1].v.k` (x15). The law recurses operations
    only.
  * A port connection gives golden `work@dut.u.x.sd[D - 1].v.D`, with the instance and port in the prefix (x19,
    stage 1).
* **V4 (§ psBoundBareRefByBase145 frontier).**
  * A hier_path member select gives golden `work@dut.s.f[W:L].f.W` (x11). The modport form is
    `work@c.bus.d[H:L].d.H` (x14).
  * A folded package-parameter bound's ts ref: golden `work@dut`, ours `work@dut.a` (x17).
  * A qualified bound constant's endcol differs (x18).
  * A generate-if process part_select is named `work@dut.g.a` in golden (x20).
  * A struct-parameter member bound (x23) differs.
* **V5 (§ unaryOperandParamOwnerName145 frontier).**
  * An imported package parameter under a unary operator gives golden `work@dut`, ours `work@dut.g` (uop/x11). The
    `outerParam8` fold admits instance-body parameters only.
  * A top-level `~M` is folded by golden to one constant (x12, stage 1).
* **V6 (§ impElabArithWholeSpan145 frontier).** The package's own listing of a parenthesized
  (`(S + 8) / 8`, golden 4:31-38) or cast (`int'(S/8)`, golden 4:31-40) initializer keeps our inner span.

## 7. Files

* `dfi/ usp/ psb/ uop/ lpb/ bso/ iaw/`: the 107 break cases, each naming its law on its first line.
* `drivers/`: `env.sh`, `rc.sh` (golden plus binaries plus uhdm-cmp plus strict), `dd.sh` (dump distance),
  `reccheck.py` (record check), `attr.py` (single-switch attribution), `uvmob.py` and `obgold.py` (order-blind
  distances), `bytes.sh` (earlier-pass byte controls).
* `evidence/`: sweeps P/L/V, change list, record checks, byteverify (law vs pristine, verified vs law), probe movers,
  switch attribution, grid table, stage-1 distances, earlier-pass controls, downstream summaries and target rows.
