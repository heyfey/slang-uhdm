# v11u430 — adversarial verification of r11u430 (module/type ground, pass 430)

Base f713a2062. Implementer's patch /tmp/r11u430.patch applied clean on a fresh
worktree (/tmp/wt_v11u430). Pristine reading: the master's control sweep
/tmp/intr11u428; no pristine build, no pristine sweep (measurement budget). Pristine
binary for case runs: the main tree's build/slang-uhdm frozen at
/tmp/v11u430_bin/pristine (md5 65e4ae8b4a83a4366e3a2c1c7eb371f6).

VERDICT: the five laws reproduce bit for bit, but there is ONE BREAK, in
§ defGenLpRangedTs430's elaborated half. The fix is § rngGenLpCaReadShape430v
(below). The verified binary passes the full five-stage gate.

## Binaries (frozen before measurement)

| binary | md5 | use |
|---|---|---|
| /tmp/v11u430_bin/law | ce2b1c0700aa7b98649896ffca6cb8a1 | law rebuilt once; equals the implementer's final/law11 |
| /tmp/v11u430_bin/verified1 | 6b695fbe441caaf0e89f61cdb46ffcea | intermediate refinement; case runs only, never swept |
| /tmp/v11u430_bin/verified | 60d3ffba6f056d6d32b8c5230a29b9c9 | final verified binary; links slang 12.0.0+545f88b2e |

## Headline numbers reproduced (law sweep, drivers/fullsweep.sh, workdir /tmp/v11u430sw1, trace on)

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69, regressions=0 conversions=0 changes=0; csv identical to the control.
- surelog: 480 + 474 CMP_EQUAL, 0/0/0. The csv differs from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical to the control.
- downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; csv identical to the control.
- sv-tests: EQUAL 1891, STRICT_NOTEQUAL 6, DIFFERENT 43, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=2 changes=0. The csv is byte-identical to the
  implementer's (/tmp/r11u430sw2/svtests.csv) on all 2346 rows:
  - `chapter-18/18.14--random-stability_1.sv,EQUAL,,equal` (was DIFFERENT; § clsArrPropConcatInitElemSize430)
  - `chapter-7/structures/unpacked/default-value.sv,EQUAL,,equal` (was DIFFERENT; § structMemberDefaultParamRef430)
- byteverify law against the control (SELFCHECK=1): 0 of 962, 0 of 1608 and 0 of 805, self-checks n-1 of n.
- canaries ok=52 and ok=16 (changed 0); ctcan2 ok=58 / unknown 1 and ok=2 / unknown 6, both PASS.
- trace census: exactly 3 databases fire, all sv-tests rows: 18.14_1 (CLSARRCONCAT x2), default-value
  (MEMBERDEFPARAM def + elab) and bsg_mul_pipelined (GENLPNOBLOCK x3, GENLPRANGEDTS x11). No corpus row and no
  probe case fires. § modArrConcatInitElemSize430 fires nowhere in the gate. It is measured only on cases.
- The implementer's 34-case grid was reproduced on exit code, uhdm-cmp count and strict verdict for all 34 lines
  (evidence/grid3_r11u430cases.txt). The verified binary writes the law's bytes on all 34. R11U430_OFF gives
  pristine's bytes, and each case's own switch alone gives pristine's bytes, on 34 of 34.

## THE BREAK and the refinement

§ defGenLpRangedTs430's elaborated half added `rng430` to the old typed-localparam rule (§ genLpPortConnRead10):
any continuous-assignment read gives the param_assign constant the bare loc-less logic_typespec clone. This is
right for a typed localparam, as grid B measured. For a ranged UNTYPED one, golden keeps the declaration's
int_typespec on most expression reads. Example: `localparam [7:0] a = 5; assign o = i + a;` in a generate
block. Golden's constant references `int_typespec 3:16-3:21`. Pristine referenced an int_typespec, with only
its span wrong. The law writes `logic_typespec` (no location). That is a judge-visible typespec kind moving
away from golden. Cases: VR/vr06, vr11 and vr15 (if or case generate, `i + a`, `i << a`) and vr16
(`i[a[1:0] + b[0]]`), all closer by dump distance overall but with this cell new-wrong.

Golden's shape, measured on 48 read shapes (vr17 to vr52, evidence/vr_shape_map.txt):

- BARE (golden uses the clone) for: `a`, `~a`, `-a`, `!a`, `a + 1`, `a + i`, `a - i`, `a & i`, `a << i`,
  `(a) + i`, `a + i + 1`, `i + 1 + a`, `2 + a`, `k + a`, `a ? i : 0`, `i == 0 ? a : i`, `i[0] ? a : i`,
  `i > 2 ? a : 0`, `i[a]`, `i[a[2:0]]`, `i[a - 3]`, `{a, i}`, `{a}`.
- DECLARATION typespec for: `i + a`, `i - a`, `i & a`, `i << a`, `i * a`, `i[3:0] + a`, `a[3:0] + i`, `-a + i`,
  `~a + i`, `8'(a) + i`, `1 + a + i`, `i + (a + 1)`, `{i[3:0], a[3:0]}`, `{a[3:0], i[3:0]}`, `i ? a : i`,
  `(i == 0) ? i : a`, `i[a[2:0] +: 2]`, and a left-side select `o[a[2:0]] = ...`.

§ rngGenLpCaReadShape430v (R11V430_RNGCAREAD_OFF; src/ModuleEmit.cpp emitTopPorts, in the scanCa9 continuous
assignment branch) applies only to a ranged untyped localparam. A continuous assignment counts as a read only
when its right side has a measured BARE shape:
- the name itself;
- a unary operator on the name, only as the whole right side;
- a binary operation whose left operand is the name;
- a binary operation whose right operand is the name, after a left operand that is an operation, or after a
  constant when it is the whole right side;
- an operation whose left operand is such an operation;
- a conditional whose predicate is the name, or whose true branch is the name after a predicate that is not a
  plain name;
- a bit-select whose index is the name, a select of it, or an index expression of such a shape;
- a concatenation that opens with the name.

Typed localparams keep the old visitor, so their bytes do not change. Port connections are unchanged. Each
judged continuous assignment logs through lawTrace(430, "rngGenLpCaReadShape430v", "bare|decl <name>"). No
getenv, no src/R*.h, no reader function. R11V430_OFF gives the law's bytes on every case.

The intermediate verified1 also counted `i[a - 3]` and `i[a + b]` as declaration reads. That moved vr02 and vr08
from STRICT_EQUAL to NOT_EQUAL, so the index rule was widened before the final build. verified1 was never swept.

## Verified sweep (drivers/fullsweep2.sh, workdir /tmp/v11u430sw2, trace on)

- All five stages read exactly as the law sweep: the probe, surelog, uhdm2rtlil, downstream and svtests csvs
  are identical to the law sweep's after the workdir name. regressions=0 everywhere; sv-tests conversions=2
  (the same two rows), changes=0.
- byteverify verified against the control and verified against law: 0 of 962, 0 of 1608 and 0 of 805, self-checks passing.
- trace: the refinement logs nothing in any stage. No corpus row, probe case or sv-tests row reaches its
  branch; the law firings are the same 3 sv-tests databases.
- away census on the 70 kept sv-tests databases, law against verified (path-normalized uhdm-dump):
  69 of 69 identical. tnoc is the same size on both (230131612 bytes) and the refinement does not fire on it.

## Attack grid (134 fresh case dirs, evidence/grid3.txt; every case accepted by upstream slang, every golden at 0 Surelog errors and 0 fatals, every exit code 0 on all three binaries)

Groups: VA (19, class fixed-array concatenation), VM (24, module/interface/program/function arrays), VD (18,
struct member defaults), VG (16, unbuilt generate blocks), VR (57, ranged generate localparams and their reads).

- pristine -> law: 68 NOT_EQUAL -> STRICT_EQUAL, 2 NOT_EQUAL -> STRICT_NOTEQUAL (vr03 endcol, vd16 type),
  12 STRICT_EQUAL controls, 52 NOT_EQUAL on both.
- pristine -> verified: 88 NOT_EQUAL -> STRICT_EQUAL, 2 NOT_EQUAL -> STRICT_NOTEQUAL, 12 STRICT_EQUAL controls
  byte-identical to pristine, 32 NOT_EQUAL on both. Of those 32, 29 are closer by normalized dump distance and
  3 are unchanged; none is further. The refinement takes 20 cases from law NOT_EQUAL to STRICT_EQUAL (vr11, vr15,
  vr17, vr19, vr20, vr22, vr25, vr28 to vr33, vr36, vr38 to vr40, vr44, vr48, vr50), and no case it touches gets worse.
- On every case: R11U430_OFF on verified gives pristine's bytes and exit code; R11V430_OFF gives the law's bytes;
  each law's own switch gives pristine's bytes, and the refinement's own switch gives the law's bytes.
- New wrong cells on the 32 unequal cases are all on objects pristine did not write at all (evidence/dist_unequal.txt):
  - an unsized based operand left at size -1 where golden sizes it to the element (VM/vm08 `'h2`, vm18, VA/va04);
  - a genvar operand parented at the operation (vm17);
  - a parameter operand written as a ref_obj where golden folds it to the param_assign constant (vm20);
  - a parameterized class's size line (va09);
  - value encodings DEC/INT against UINT that pristine also has (vr06, vr41 `-a` 251 against INT:-5).
- Downstream (evidence/dsgrid3.txt, 115 class-free cases, three binaries): VM/vm05 and vm17 go
  EQUIVALENT -> IDENTICAL on law and verified, 112 stay IDENTICAL, and VD/vd16 is DIVERGENT on all three.
  None is worse.

Cases and their laws: § clsArrPropConcatInitElemSize430 VA/va01-va19; § modArrConcatInitElemSize430
VM/vm01-vm24; § structMemberDefaultParamRef430 VD/vd01-vd18; § defGenLpNoBlockListed430 VG/vg01-vg16;
§ defGenLpRangedTs430 VR/vr01-vr05, vr07-vr10, vr12-vr14, vr18, vr21, vr23, vr24, vr26, vr27, vr34, vr35,
vr37, vr41-vr43, vr45-vr47, vr49, vr51-vr57; § rngGenLpCaReadShape430v VR/vr06, vr11, vr15, vr16, vr17, vr19,
vr20, vr22, vr25, vr28-vr33, vr36, vr38-vr40, vr44, vr48, vr50.

## Earlier-pass census (drivers/census.sh, pristine against verified, bytes)

3801 fence-filtered case dirs of tools/probe/r11u401repro to r11u428repro and their v11u twins
(evidence/census_pristine_vs_verified.txt):
- 3790 are byte-identical.
- 8 write no database on either binary (exit 3 on both).
- 3 move, all toward golden: r11u414repro SD/sd01 and r11u424repro DV/dv01 go NOT_EQUAL -> STRICT_EQUAL
  (struct member defaults naming a parameter, pass 424's dv01 residue); r11u410repro GP/gp07 has uhdm-cmp
  47 -> 14 and dump distance 275 -> 203.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The typed-localparam twin of the break: `localparam logic [7:0] a = 5; assign o = i + a;` is still bare where
   golden keeps the declaration typespec. This is pristine behaviour of § genLpPortConnRead10, not written:
   vr53 NOT_EQUAL on all three binaries, while vr54 `a + i` and vr55 `i[a]` are STRICT_EQUAL controls. The
   shape predicate of § rngGenLpCaReadShape430v would serve the typed rule too, but it needs its own grid
   against grid B's ca/caexpr cells.
2. Array concatenation initializers: unsized based operands (`'h2`) at size -1 where golden takes the element
   width (VM/vm08, vm18, VA/va04); parameter operands golden folds (vm20, the implementer's ca10); genvar
   operands in a generate scope (vm17); a parameterized class's element size (va09).
3. Struct member defaults: unsized based or typed or overridden or negative parameters (VD/vd04, vd05, vd06,
   vd08, vd13, vd15, vd18), interfaces (vd10), generate blocks (vd11), procedural blocks (vd12), and vd16's
   type(1) with downstream DIVERGENT.
4. Unbuilt generate blocks: `parameter` in place of localparam (VG/vg07), `integer`, unsized based and real
   localparams (vg11), interfaces (vg15).
5. Ranged localparams: a non-literal bound `[N-1:0]` (VR/vr07), signed (vr09), a packed range with unpacked
   dimensions (vr12), interfaces (vr13), the value encodings DEC/INT (vr06, vr41), vr03's endcol.
6. The implementer's residues stand: ParamEmit makeParamTs override width (bsg_mul_pipelined, sister ground),
   GL/gl12, CA/ca10-ca12, DM/dm02, dm03, dm05, dm07, and the carried backlog.

## Sister-ground faces (reported, not written)

- ParamEmit makeParamTs: the override-width range (bsg_mul_pipelined's next head; the implementer's repro).
- ExprEmit: `-a` folded as UINT:251 where golden has INT:-5 (VR/vr41); `{a}` and the unsized-based
  concatenation operands (VM/vm08).

## Process

- Measured within the budget: one law build, two verified builds (verified1 case runs only), one full sweep
  each on law and verified, and no pristine build or sweep.
- Slips, none affecting a measurement:
  - The first verified build started while the sister v11u427's sweep was live; the pgrep before it printed 2,
    and I did not wait.
  - The second verified build and a 57-case VR grid overlapped the first two minutes of the sister's
    relaunched sweep.
  - The 115-case downstream grid and 47 sv-tests dump comparisons ran while the sister's verified sweep was
    live. I stopped the dump comparisons by task id and finished them on a quiet machine.
  - The first census reading counted 8 no-database pairs as movers; the driver was fixed.
  - One golden was built for a draft vr15 that Surelog rejects (a bare begin block). It was deleted and the
    case rewritten.
- The fence list was read into a file by a program and never printed; every tree-wide list was filtered on it
  first. No fenced test was named, opened or run, and no other agent's process was touched.
