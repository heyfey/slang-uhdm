# v11u487: adversarial verification of r11u487

Verdict: CONFIRMED WITH TWO BREAKS FIXED by two refinements in `src/ParamEmit.cpp`.
Base 791b52f7. The law binary was rebuilt from `/tmp/r11u487.patch` and equals the implementer's
law10 (md5 9c396cfc89dce21a98410d645b837d9e, slang 12.0.0+545f88b2e). The verified binary has
md5 be131321b16f205e06dbe22e96ac575b. The pristine binary is a frozen copy of the main tree's
base build (md5 f6a346fb81377618674f89230eef4973); no pristine build and no pristine sweep were
made, and the pristine sweep reading is the master's control `/tmp/intr11u485`.

## The two breaks (legal SV accepted by upstream slang, pristine right, the law wrong)

1. **§ bareOvRefUint64_487 on a bare-name override actual** (cases VB/vb12, vb19, vb25, vb28).
   With `m #(.A(P))`, `.A((P))` or `#(P)`, where P is a parameter visible at the
   instantiation, golden copies P's own elaborated constant. So `localparam B = A` keeps size 32
   in golden, as pristine wrote it. The law wrote size 64.
   - vb12: STRICT_EQUAL on B's cell in pristine; the law moved uhdm-cmp from 17 to 36 lines.
   - The grid of actual forms decides the rule: a literal `(5)` (vb17), `2+3` (vb18), `P+0`
     (vb20), `p::P` (vb26) and a genvar `i` (vb27) all read size 64 in golden, as the law writes.
     A bare name `P` (vb19), `(P)` (vb25) and ordered `#(P)` (vb28) read size 32.
   - Fix: **§ bareOvRefParamActual487v** (`R11V487_OVREFNAME_OFF`). When the written actual,
     stripped of parentheses, is an IdentifierName, the law abstains unless the name resolves at
     the instantiation to a genvar's parameter (`ParameterSymbol::isFromGenvar`).
   - Result: vb12, vb19, vb25 and vb28 go to STRICT_EQUAL. vb29 (P = 'h5) goes back to B's
     pristine size 32; golden there writes HEX at size 8, an older face.
2. **instOvActual487 ignoring type parameters in the ordered slots** (cases VD/vd01, vd23).
   The ordered-override map counted only value parameters. With
   `#(parameter type T = int, parameter A = 4, parameter C = 2)` and `m #(int, 9)`, it gave C the 9.
   - vd23 (`defparam u.C = 2`, `localparam B = C + 1`): golden and pristine read B = 3, and
     § dpDepPreDefparamValue487 wrote 10. uhdm-cmp went 17 -> 36, and downstream went
     IDENTICAL on pristine -> EQUIVALENT on the law.
   - vd01 (`m #(int, 9, 3)`, `defparam u.C = 7`): golden reads 4, pristine 8 and the law 10.
   - Fix: **§ ovOrderedTypeParamSlot487v** (`R11V487_TPSLOT_OFF`). Non-local type parameters
     take their ordered slot, and count as port parameters for the port-list test.
   - Result: vd01 and vd23 go to STRICT_EQUAL, and vd23 is IDENTICAL downstream again.

Both refinements go through `fixOn(487, ...)`; `R11V487_OFF` drops both. There is no `src/R*.h`,
no `getenv`, no include and no header change. ParamEmit is the only production file touched.

## Switches (evidence/switches.txt, 220 case dirs: this grid's 118 and the implementer's 102)
- Every dir has outputs deleted before each run, and its exit code is recorded.
- On the verified binary, `R11V487_OFF=1` gives the law's bytes on 220 of 220 dirs, and
  `R11U487_OFF=1` gives pristine's bytes and exit code on 220 of 220.
- `R11V487_OVREFNAME_OFF` alone moves exactly vb12, vb19, vb25, vb28 and vb29 back to the law's
  bytes, and `R11V487_TPSLOT_OFF` alone moves exactly vd01 and vd23.
- The verified binary differs from the law on those 7 dirs only; on the implementer's 102 dirs
  it is byte-identical to the law.

## Reproduction of the implementer's numbers
- **Patch:** `/tmp/r11u487.patch` applies cleanly on a fresh 791b52f7; the rebuilt law binary's
  md5 equals law10.
- **Implementer's grid** (102 dirs, evidence/impl_grid_*.txt): pristine STRICT_EQUAL 17 and
  NOT_EQUAL 85; law 87 and 15; every exit code 0. These equal the implementer's
  grid_pristine.txt and grid_law10.txt line for line on exit code, uhdm-cmp count and verdict.
  The md5 column differs only by the embedded worktree path. Verified equals law on all 102.
- **Away census** (evidence/away_census.txt): 14493 fence-filtered case dirs. They are the union
  of the implementer's 10621-dir list with every tools/probe dir whose source holds `#(` or
  `defparam`, 11545 dirs.
  - No exit code moves on any of the three binaries.
  - Pristine -> law: exactly the implementer's 34 byte movers. Judged against golden, 21 reach
    STRICT_EQUAL and 2 reach STRICT_NOTEQUAL (cx/x06, NU/nu05). The other 11 keep their verdict
    and uhdm-cmp count, and all 34 are closer by dump distance.
  - Law -> verified: 0 byte movers.
- **Law sweep** (one five-stage sweep on the law binary, `R11U487_TRACE` on; evidence/sweep_law.txt):

  | Stage | Result | regressions / conversions / changes |
  |---|---|---|
  | probe | EQUAL 4025 + STRICT_NOTEQUAL 62 | 0 / 0 / 0 |
  | surelog | default 480 + testflags 474 CMP_EQUAL | 0 / 0 / 0 |
  | uhdm2rtlil | 803 / 1 / 67 in both modes | 0 / 0 / 0 |
  | downstream | 803 / 66 / 2 / 0 | 0 not excused |
  | sv-tests | EQUAL 1936, STRICT_NOTEQUAL 1, DIFFERENT 3, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | 0 / 0 / 0 |

  - Every csv equals the control's row for row, except the two LowMem testflags log-path texts in
    surelog.csv.
  - The trace directory stayed empty.
  - The corpus stage's rc 1 is the law-index check alone: this verifier's cases were added after
    the last regeneration.
  - byteverify against the control (evidence/byteverify_all.txt) reads surelog 0 of 962, uhdm2rtlil 0 of 1608 and downstream
    0 of 805 movers. SELFCHECK flags 961, 1607 and 804.
  - Canaries read ok=52 and ok=16, both with changed=0, and both ctcan2 checks PASS.
  - Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the law binary (the other 50
    hold only a Surelog line), uhdm2rtlil 1740 of 1740 and sv-tests 2346 of 2346. No other binary
    is named anywhere.
- **Target row:** `generated/uvm-examples/uvm_param_vif_config_db.sv,STRICT_NOTEQUAL,differ:fullname(3),differ:fullname(3)`,
  unchanged. Its faces are on the sister's ground.
- **Goal 1** (evidence/goal1.txt): `C::mk().arr[1]` and `u.mk(3).a[2]` exit 4 on law and
  verified, 0 in upstream slang and 3 in Surelog. `this.mk().inner.s` exits 0, 0 and 3. All 75
  SURELOG_ONLY details are slang `error:` diagnostics, none the exporter's own message.
  bp_unicore was not re-measured here; it stays SURELOG_CRASH with the guard untouched.

## Attack grid (cases/, 118 fresh dirs; each case's first line names its law)
Upstream slang accepts all 118 (real exit code 0; the negative control reads 1). Surelog writes a
golden for all 118, and every exit code is 0 on all three binaries.

| Group | Dirs | Law | What it attacks |
|---|---|---|---|
| VD | 27 | § dpDepPreDefparamValue487 | hierarchical, generate-scope, array-instance, interface, self-top and body-parameter defparams; chains, typed dependents, conditionals, negative values, ordered overrides with type parameters |
| VB | 28 | § bareOvRefUint64_487 | override actual forms, interfaces, port parameters, two instances, a child override |
| VG | 15 | § caFoldLhsWidthGrow487 | int, packed 2-D, part-select, signed, typedef, packed-struct, net-declaration, interface, 1-bit and nested left sides |
| VM | 21 | § ovDefparamMaskWidth487 | byte, shortint, integer, bit, implicit `[3:0]`, `[7:4]`, `[0:0]`, signed and hierarchical defparams |
| VT | 15 | § caFoldTsFollowsPa487 | literal, sized, x, 64-bit, negative, $clog2, concatenation, enum, package and overridden-parameter folds |
| VV | 12 | § caFoldValueFollowsPa487 | $bits of a base-less enum, unsized hex, package reads, class-scoped overrides, x, 3000000000, casts, conditionals, shifts |

| Binary | STRICT_EQUAL | STRICT_NOTEQUAL | NOT_EQUAL |
|---|---|---|---|
| pristine | 27 | 1 | 90 |
| law | 79 | 2 | 37 |
| verified | 85 | 2 | 31 |

- On the verified binary, no dir is further from golden than on pristine (evidence/dist_pristine_vs_ver.txt):
  - Of the 33 dirs still not STRICT_EQUAL, 15 are closer by dump distance and 18 keep pristine's
    distance.
  - VD/vd13's uhdm-cmp count grows 36 -> 64, but its dump distance falls 12 -> 8 and its head
    moves later: B is now right, and the head is the child's override X.
- Downstream (evidence/downstream_*.txt):

  | Binary | IDENTICAL | EQUIVALENT | DIVERGENT | STATUS_DIFF |
  |---|---|---|---|---|
  | pristine | 71 | 44 | 2 | 1 |
  | law | 107 | 10 | 0 | 1 |
  | verified | 109 | 8 | 0 | 1 |

  - The one dir that left IDENTICAL on the law, VD/vd23, is IDENTICAL on the verified binary.
  - VD/vd14's STATUS_DIFF is the slang lane's READ_FAIL on all three binaries.

## Verified sweep (one five-stage sweep on the verified binary, `R11U487_TRACE` on; evidence/sweep_ver.txt)
- The stage readings equal the law sweep's: probe 4025 + 62, surelog 480 + 474, uhdm2rtlil
  803/1/67 in both modes, downstream 803/66/2/0 and sv-tests EQUAL 1936 / STRICT_NOTEQUAL 1 /
  DIFFERENT 3. Every stage reads regressions=0, conversions=0 and changes=0, and the corpus stage
  rc is 0 with the law index current.
- Every csv equals the law sweep's row for row, and the control's except the two LowMem log-path
  texts.
- The trace directory stayed empty: neither the laws nor the refinements fired in any process.
- byteverify (evidence/byteverify_all.txt) reads 0 movers for verified against law, verified
  against control and law against control: surelog 0 of 962, uhdm2rtlil 0 of 1608 and
  downstream 0 of 805, with SELFCHECK flagging all but one each time.
- Probe databases: 0 of 4087 movers, verified against law by workdir-normalised bytes and law
  against control by path-normalised dumps. The shifted-pair negative control flags 4085 of 4086.
- Canaries read ok=52 and ok=16, both with changed=0, and both ctcan2 checks PASS.
- Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the verified binary (the other
  50 hold only a Surelog line), uhdm2rtlil 1740 of 1740 and sv-tests 2346 of 2346.

## Findings that are not breaks
- § dpDepPreDefparamValue487's comment says the pre-defparam value is "an unsized decimal or a
  sized 'd literal (any other form abstains)". `lit487` also values h, o and b bases. The comment
  claims less than the code does; the bytes on the grid are golden's (VD).
- ev487 evaluates with slang's post-defparam operand types where Surelog evaluates unbounded:
  `parameter A = 4'd15`, `localparam B = A + 4'd1` with `defparam u.A = 6` reads 16 in golden,
  7 on pristine and 0 on the law (VD/vd14, the same dump distance as pristine).

## Residues (all wrong on pristine too; none moved away on the verified binary)
1. A child override that reads a defparam-dependent parameter, `n #(.X(B))`: golden's X follows
   B's pre-defparam value, and ours keeps slang's (VD/vd13).
2. ev487's width model (VD/vd14 above).
3. A dependent inside a generate block (vd10) or a typed `localparam logic [2:0] B = A + 3`
   (vd11): vd10 is untouched, and vd11 is closer (8 -> 4).
4. An overridden parameter whose actual is a parameter holding an unsized hex: golden copies the
   HEX form at size 8 into A and B (VB/vb29).
5. A defparam with no instance override, where § ovDefparamWinsValue485 does not apply, so neither
   that law nor the mask law fires (VM/vm01, vm03, vm06, vm07, vm10, vm11). This is the
   implementer's ModuleEmit drain face.
6. An implicit-type `parameter [3:0] A` with an override and a defparam: the value is now right,
   at a later face (vm16, 30 -> 24).
7. The generate-scope and interface continuous-assignment folds (VD/vd08, VB/vb04, VG/vg08), and
   the typedef left side (vg05, 103 -> 101).
8. The implementer's ranked residues stand as written.

## Sister-ground faces
None new. The implementer's three ModuleEmit faces are confirmed by VM/vm01–vm11 and VG/vg08.

## Process
- The law binary was built once and the verified binary once (one refinement build). There is one
  five-stage sweep on each.
- **Slip 1, timing only:** this verifier's grid runs, switch checks, downstream case runs and the
  nice'd away census overlapped the sister v11u480's sweep (02:43 to about 03:11).
- **Slip 2:** this verifier's first sweep launcher counted the implementer's leftover wait loop,
  whose command line spells the sweep patterns, as live. The launcher never started; it was stopped
  by its own PID and relaunched with a pattern anchored on the real sweep processes.
- **Fence:** the fence list was read into a file by a program, never printed, and every tree-wide
  list was filtered on it first. The patch and both repro folders scan clean.
