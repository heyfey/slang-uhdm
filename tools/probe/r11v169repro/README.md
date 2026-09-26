# r11v169 — adversarial verification of r11u169: every headline number reproduced, one break found and refined (a folded parameter inside an `inside` set keeps the instance's name), the four laws each droppable alone

Base `45b8e774` (branch matrix-1.87, pass 167). Verified patch = the r11u169 patch plus one refinement in
`src/ExprEmit.cpp` (§ gcaChainInsideSetKeepsInst169v, switch `R11V169_INSIDESET_OFF`) and this directory. Worktrees
`/tmp/wt_v11u169` (patched) and `/tmp/wt_v11u169pris` (pristine), system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base; equals the main tree's build of the base) | `d64816326230eb41669e1062297ba547` |
| law (the r11u169 patch as delivered; equals the implementer's `law8`) | `4a1d1f4cff4ddff0f8fdbf259ed587f4` |
| law + refinement (`fix1`) | `499dafc400a0f122b18daf3fcaffc4d6` |
| `build/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` |

All three frozen (`chmod 555`) before any measurement. Sweeps `/tmp/v11u169_swP` (pristine), `/tmp/v11u169_swL`
(law), `/tmp/v11u169_swF` (law + refinement), and `/tmp/v11u169_swQ` (pristine probe stage run from the patched
worktree, so probe databases carry the same source paths as the law sweep's). Every `cmds.txt` slang line names the
frozen binary of its own sweep: 1531 surelog + 1742 uhdm2rtlil lines per sweep, one binary each. The downstream
harness writes no `cmds.txt`; its binary identity is shown by bytes: the downstream `slang.uhdm` of the law sweep
differs from pristine's on exactly ibex_pmp, param_nested_struct_field_width, pkg_nested_struct_param_width,
struct_param_field_shift and struct_param_func_config (805 paths), and the refinement sweep's equals the law
sweep's on all 805. Pass 168 (sister ground) landed on the main tree after the base (`f34d9d7c`); every measurement
here is at `45b8e774`.

**The fence.** No binary, script or scan touched a slang-fenced test's source or database outside the gate
sweeps. drivers/env.sh reads the four names from RESUME.md; drivers/grid.sh refuses to run without them and
refuses a fenced path; the Earlgrey and ibex_pmp trace runs are non-fenced corpus rows; nothing in this directory
spells a fenced name.

## Reproduction of the implementer's numbers (all bit-for-bit)

| claim | measured |
|---|---|
| pristine sweep: 0/0/0 in all stages, probe EQUAL 2676 / STRICT_NOTEQUAL 1411, downstream 803/66/2 | same |
| law probe: EQUAL 2734 / 1353, regressions 0, conversions 58, changes 27 | same, the same 58 + 27 names |
| law surelog: regressions 0, conversions 0, changes 2 (FuncStructVal d/t endcol 207→95, 363→177) | same |
| law uhdm2rtlil: regressions 0, conversions 2 (pkg_nested_struct_param_width d/t), changes 8 | same; `pkg_nested_struct_param_width,default,CMP_EQUAL,,,equal` and `...,testflags,CMP_EQUAL,,,equal` |
| law downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, csv byte-identical to pristine's | same (`cmp` reads identical) |
| the grown counts walk further (param_nested_struct_field_width, struct_param_func_config) | pristine walk diverged at `#239 depth` / `#301 depth`; every law record lies beyond (`#789 ...`, `#697 ... #1364 depth`); struct_param_field_shift's law records are a subset of pristine's |
| byte movers: surelog 10 predicted + UVM coins, uhdm2rtlil 10/10, probe 98/98 | surelog 15 movers this draw: the 10 predicted + MiniAmiq d/t, SeqDriver d/t (4-line UINT/vpiDecompile coin), Scoreboard d (92 ordered, 0 order-blind lines); uhdm2rtlil 10/10; probe 98 movers = the 98 predicted names exactly |
| canaries | surelog ok=50 changed=2 (FuncStructVal d/t), uhdm2rtlil ok=16; ctcan2 PASS both (ok=58 / ok=2) |
| `R11U169_OFF=1` byte-identical to pristine on 1646 cases; with laws on only rs/r07, rs/r10, gz/z03 move among the earlier passes' cases | same: 1646/1646 (7 rejected by both), earlier-pass movers exactly those three (evidence/offbytes_1646.txt) |
| each switch alone returns its grid to pristine bytes | same, on the implementer's 64 cases and on the 102 fresh cases here, with the other grids untouched (evidence/switches_raw.txt) |
| r11u170 item (3) | spot-checked: `R11U163_TPDEFNAME_OFF` adds exactly `#119 ref_obj IW <in>IT.IW / <in>IW` on probe r11u20repro/t6; `R11U158_AGGUNQSPAN_OFF` on r11vu13 v4/v9 is dump-identical (bytes differ, strict records identical) |

## The break: § genCaFoldTsChainNamed169 names an inside-set member by the scope

102 fresh cases (cases/gc gi ml pf; each judged by uhdm-cmp, uhdm-strictcmp against the v1.87 pin, and a
multiset dump comparison `drivers/toward.py` counting pristine lines golden holds that the patched binary loses).
The ML, PF and all non-inside GC cases hold: no case loses a line toward golden, 19 gc cases and 8 pf cases go
STRICT_NOTEQUAL → STRICT_EQUAL (casts `8'(P)`, `int'(P)`, conditional operands, shifts, `**`, `%`, `/`, `!=`,
nested concatenation/replication operands, localparam, child instance with override, 2-D select, macro-born operand,
hex `c5` copy), `-P`, `~P`, `{P, ...}`, `!P`, `&P` direct operands stay pristine and equal. ML: every leftover moved
toward golden (`mk(64, 11 - 3)`: golden and ours 18:31-33; `mk(PW, 5)`: 18:27-29; `32'h40`: 18:27-33), none lost.
PF: the unary operator-token rule holds on `-1`, `-A`, `!A`, `-(A + 1)`; binary left-operand on `==`, `&&`, `**`,
`>=`, macro operands, header-parameter defaults, a child instance.

**Pristine-right → patched-wrong on legal SV (six cases):** a folded module parameter that is a member of an
`inside` SET, directly or as a range bound. Golden keeps the substituted constant at its param_assign and the
`ref_typespec` named `work@dut`; the law walked through the inside operation and named it `work@dut.g[0]`:

| case | expression | pristine | law | law + refinement |
|---|---|---|---|---|
| gi/i05 | `{a[c][0] inside {P}, 31'b0}` | STRICT_EQUAL | **fullname(2)** (`#136 ref_typespec A: work@dut B: work@dut.g[0]`) | STRICT_EQUAL |
| gi/i06 | `a[c] inside {P, 1} ? a[c] : 0` | STRICT_EQUAL | **fullname(2)** | STRICT_EQUAL |
| gi/i01 | `32'(a[c] inside {P, 3})` | fullname(4) | fullname(6) | fullname(4) (pristine bytes) |
| gi/i02 | `32'(a[c] inside {P})` | fullname(4) | fullname(6) | pristine bytes |
| gi/i03 | `32'(a[c] inside {[P:9]})` | stage 1 | stage 1, 6 dump lines lost | pristine bytes |
| gi/i04 | `32'(a[c] inside {[1:P]})` | stage 1 | stage 1, 6 dump lines lost | pristine bytes |

Controls: gi/i08 `P inside {a[c], 3}` (the LEFT operand: the law's scope name is kept, 2 lines toward golden);
gi/i07 `{P + 1, 2}` (golden leaves that reference's full name empty: scope and instance are both wrong, the
refinement restores pristine bytes); gi/i09 `{a[c][P], 1}` (golden `a`, unchanged by the refinement: the walk
stops at the select); gi/i10 `{~P}` (the unary abstention, unchanged). Downstream verdicts (drivers/ds.sh) on
18 fresh cases are the same on all three binaries (IDENTICAL, ml/mb17 EQUIVALENT on all three).

### § gcaChainInsideSetKeepsInst169v (`R11V169_INSIDESET_OFF`; ExprEmit.cpp, genCaUseSiteChainName169 and the Inside case of emitExpr)
A folded parameter that is a member of an inside SET, directly (`a inside {P, 3}`) or as a range bound
(`a inside {[P:9]}`), keeps the instance's name: the walk of § genCaFoldTsChainNamed169 abstains when it reaches an
inside operation whose set members are being emitted (the Inside case registers the operation after emitting its
left operand and releases it after the set). The left operand is not a set member and keeps the law. Trace
`GCACHAIN insideset abstain`. Cases gi/i01-i10.

Census before the gate sweep: the refinement can only move bytes where `GCACHAIN c9`/`c5` renamed (the
implementer's census: 59 probe cases, Earlgrey_0_1 d/t, ibex_pmp d/t); `R11U169_TRACE=1` on all 59 probe cases,
Earlgrey (both modes) and ibex_pmp (both modes) reads 0 `insideset` firings (positive control: gi/i02 reads 2).
Predicted movers against the law sweep: none. Measured (law + refinement vs law): probe 0 of 4087, uhdm2rtlil 0 of
1608, surelog 4 of 960 = MiniAmiq d/t and SeqDriver d/t, the 4-line UINT/vpiDecompile coin (ordered 4 = order-blind
4, `vpiDecompile:1386 / 1201`); downstream databases 0 of 805.

## Gates (law + refinement, `/tmp/v11u169_swF`)

| gate | result |
|---|---|
| (1) build, md5 | pristine `d6481632…`, fix1 `499dafc4…` |
| (2) probe | regressions=0 conversions=58 changes=27; EQUAL 2734 STRICT_NOTEQUAL 1353 (the same names as the law sweep) |
| (3) surelog / uhdm2rtlil | regressions=0; conversions 0 + 2 (pkg_nested_struct_param_width d/t); changes 2 + 8 (as the law sweep) |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66; downstream.csv byte-identical to the pristine sweep's |
| (5) uhdm-cmp | every mover keeps its judge-equal status; every fresh case keeps its uhdm-cmp verdict on all three binaries |
| (6) byteverify (SELFCHECK=1) | law vs pristine: surelog 15 (10 predicted + coins), uhdm2rtlil 10/10; fix1 vs law: surelog 4 (coins), uhdm2rtlil 0; probe fix1 vs law 0 |
| canaries | canaries.sh surelog ok=50 changed=2 (FuncStructVal d/t), uhdm2rtlil ok=16; ctcan2 PASS (EXPECT_UNKNOWN=1 ok=58; EXPECT_UNKNOWN=6 ok=2) |
| switches | `R11U169_OFF=1` = pristine on 1646 cases; each of GCACHAIN / MLLOC+MLARGLOC / PATFLATSPAN alone = pristine on its grid; `R11V169_INSIDESET_OFF` = the law's bytes on the 7 cases it moves and nothing else |

## Residues (ranked; the implementer's R1-R5 stand as measured)

1. **Reference names golden leaves EMPTY** (fresh gc cases): a folded parameter under `==?`, `&&` (logical), an
   inside set member under a binary (`{P + 1}`), and the left operand of `inside` read `ref_typespec` with an empty
   full name in golden (the constant is unparented there); ours writes `work@dut` (pristine) or the scope (law).
   Neutral for this pass (same record count), next step for the chain law: an unparented-substitution rule.
2. **A select through a struct member** (`s.f[P % 8]`): golden names through a hier_path
   (`work@dut.g[0].s.f[6 % 8].f`), ours `work@dut.g[0].f` (law) / `work@dut` (pristine); stage 1 on both.
3. **The substituted constant's vpiParent**: golden re-parents a binary operand's constant at the operation (the
   name the law now writes follows from that parent); ours keeps it at the param_assign. Invisible to the strict
   records, 2 dump lines per converted case.
4. The implementer's R1 (the leftover's typespec reference on the elaborated struct copy), R2 (gc/c04, gc/a07),
   R3 (FuncStructVal INSTR_PER_FETCH), R4 (macro-born actual), R5 (LocalScopeHierPath t, a parenting face at
   uhdm_main.cpp § elabCloneFullNameUnstored137 plus ExprEmit's hier_path element).
5. Stage-1 faces on fresh ML cases (not this pass's; the laws place the leftover where golden does): a whole-formal
   read leftover keeps the ACTUAL's own size in golden (`mk(PW, 5)`: vpiSize 32, `8'd7`: vpiSize 8) where ours writes
   the member's 64-bit UINT; a defaulted formal (`mk()`) leaves golden a `ref_obj p::mk::x` at the header default
   where ours writes a constant at the call (ml/mb03, mb06, mb13 and the rest of the stage-1 ml cases).

## Files

* cases/gi (the refinement, 10), cases/gc (§ genCaFoldTsChainNamed169, 53), cases/ml (§ memLeftFormalArgLoc169 /
  § memLeftSliceUnlocated169, 24), cases/pf (§ patFlatMemberLeftSpan169, 15); each first line names its law.
* drivers/env.sh, grid.sh (golden + ours + uhdm-cmp + strictcmp), gridrow.sh (pristine / law / fix1 row),
  toward.py (multiset dump lines toward golden), offbytes.sh, switches.sh, ds.sh (downstream verdict per case).
* evidence/: grid_pristine_law_fix.txt, switches_raw.txt, offbytes_1646.txt, byteverify.txt,
  downstream_cases.txt, probe_movers_law_vs_pristine.txt (98 names = the implementer's prediction), gi_origin.txt.
