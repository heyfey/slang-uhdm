# v11u475 — adversarial verification of r11u475

Pass 475, expression/parameter ground. Base 2fa6cb00. Implementer patch /tmp/r11u475.patch.

**VERDICT: CONFIRMED, no break and no production change.** The verified patch's src diff is byte-identical to the implementer's. This folder and the regenerated tests/LAWS.md are the only additions.

## Binaries (frozen before any measurement)
| binary | path | md5 |
|---|---|---|
| pristine | /tmp/v11u475_bin/pristine | afa30e9d601c11d257df9155230c42ca (copy of the implementer's pristine, equal to the main tree's base build; no pristine build, by the budget) |
| law | /tmp/v11u475_bin/law | c36dc182efeec8aad37c0debd5d6a57f (rebuilt once from the patch in /tmp/wt_v11u475, equal to the implementer's law8; links slang 12.0.0+545f88b2e) |

Hashes are in evidence/binaries_md5.txt. No verified build was made, because nothing changed.

## Gates: one five-stage sweep on the law binary
The first four stages ran through `tests/sweep.sh --jobs 3 --workdir /tmp/v11u475_swlaw` from the worktree. The sv-tests stage ran through the main tree's scripts/check_svtests.py with `--baseline /tmp/wt_v11u475/results/golden_svtests.csv`, which is the base's golden, not the main tree's. That was needed because the worktree's UVM folder is empty, and scripts/ is identical between 2fa6cb00 and HEAD. The sweep command exited 1 only because of the law index: tests/LAWS.md was stale from this folder's new cases.

| stage | result |
|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63 of 4087, regressions 0, conversions 0, changes 0 |
| surelog | default CMP_EQUAL 480, testflags 474; 0/0/0 |
| uhdm2rtlil | 803 / 1 / 67 in both modes; 0/0/0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; not identical and not excused 0 |
| sv-tests | EQUAL 1932, DIFFERENT 8, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, conversions 0, changes 0; the csv's rows equal the base golden's rows exactly |

- **Canaries** (evidence/canaries.txt): ok=52 and ok=16; both ctcan2 checks PASS (58 and 2 rows).
- **Binary audit** (evidence/binary_audit.txt, fence-filtered): every record names the law binary.
  - surelog: 1523 of 1573 records name it; the other 50 hold only a Surelog line.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
  - No record names another slang-uhdm binary.
- **byteverify** (evidence/byteverify_vs_intr11u468.txt): the master's base control /tmp/intr11u473 had been rotated away. The control used was /tmp/intr11u468, the integration of pass 468 on this base, whose own byteverify read surelog 1 of 962 (the Scoreboard coin), u2r 0 and downstream 0. It was compared through a same-length symlink /tmp/v11u475_ctl46.
  - surelog: 1 of 962 moves, Scoreboard default, the known UVM coin.
  - uhdm2rtlil: 0 of 1608. downstream: 0 of 805.
  - The SELFCHECK flagged all but one each time.
  - probe: raw bytes differ on 4087 of 4087 because the worktree's tests/probe path is written into VpiFile. Path-normalized uhdm-dump reads SAME on 4087 of 4087, and a negative control on two different cases reads DIFF.
- **Kept sv-tests databases** (evidence/svtests_kept_vs_intr11u468.txt): 24 of 26 are STRICT_EQUAL to the control.
  - easyUVM differs because of pass 468's laws: rerunning its recorded command with `R11U475_OFF=1` gives the law's own bytes.
  - generated/rsd/rsd.sv moves through this pass. The trace shows § addOperandConstMint475 firing 42 times and § pkgReadRefChainLitForm475 5 times (RECOVERY_FROM_ACTIVE_LIST, RECOVERY_FROM_RRMT). `R11U475_OFF=1` gives other bytes. The row is SURELOG_CRASH with no golden, so its status cannot move. The implementer predicted it, and its rerun takes 98 s alone.

## The implementer's numbers, reproduced
- **Grid:** 34 dirs on both binaries (evidence/impl_grid_pristine.txt, impl_grid_law.txt). Exit code, uhdm-cmp count and strict verdict match the implementer's grid_law8.txt row for row. Bytes differ only by the case path in VpiFile.
  - 12 go to STRICT_EQUAL: am01, am02, am04, am05, am06, hc01, qr_d, qr_u, rr01, rr02, xk01 and xk04.
  - xk02 goes 86 → 112 and xk06 50 → 76 uhdm-cmp lines. In both, the first object (the whole-right-side XOR) is now golden's and the head is the nested `(A ^ B) + 1`, which pristine also writes wrong.
- **Switches** (evidence/switch_all_off.txt, switch_each.txt):
  - `R11U475_OFF=1` on the law binary gives pristine's bytes and exit code on 77 of 77 dirs (both grids).
  - Each law's own switch alone moves only the dirs it fires on; every run exits 0.
- **No-header audit:** no src/R*.h and no getenv in the added lines. Every law goes through lawOn(475, ...) and lawTrace(475, ...). The diff touches only src/ExprEmit.cpp and src/ParamEmit.cpp.

## Attack grid: 44 fresh case dirs in VA, VH, VQ, VR, VT and VX
Every case is accepted by upstream slang with its real exit code read; the negative control reads rc 1 (evidence/upstream_slang.txt). Every exit code is 0 on both binaries (evidence/attack_table.txt).

- **Pristine:** STRICT_EQUAL 12, STRICT_NOTEQUAL 2, NOT_EQUAL 30.
- **Law:** STRICT_EQUAL 34, STRICT_NOTEQUAL 2, NOT_EQUAL 8. 22 dirs reach STRICT_EQUAL newly.
- 12 dirs are byte-identical. vt02 moves bytes and stays STRICT_EQUAL.
- **No dir moves away.** No strict verdict worsens, and the referenced-tree dump distance (before the weaklyReferenced section) is lower or equal on all 78 grid dirs: 49 closer, 28 the same (evidence/grid_tree_dd.txt).
- **Downstream:** 20 movers measured on both binaries.
  - vx01, vx02, vx04, vx07, vx12 and vq06 go EQUIVALENT → IDENTICAL, and vx08 goes DIVERGENT → IDENTICAL.
  - The other 13 are IDENTICAL on both.

Cases per law:

**§ caReduceLeavesOpKept475 (VX)**
- STRICT_EQUAL on the law: vx01 (literals only), vx02 (child override, `^` and `!==`), vx03 (unary + over a parameter and a literal), vx04 (`===` / `!==` with x and z digits), vx07 ($clog2 and localparam operands), vx08 (96-bit operands) and vx12 (a grandchild under a computed override).
- Unchanged STRICT_EQUAL controls: vx05 (signal operand), vx06 (genvar operand), vx09 (net declaration assignment) and vx10 (interface).
- vx11 (`p::PA ^ p::PB`, `+p::PA`, `==?`) stays at 36 lines. The head is now a qualified operand inside the kept operation, which golden folds to INT:33 (a residue).

**§ elabImpRefDecRespell475 (VR)**
- STRICT_EQUAL on the law: vr02 (unsized 'd), vr03 (octal → UINT and hex kept) and vr05 (two-hop chain and 6'sd5).
- Unchanged STRICT_EQUAL controls: vr01 (module-local chain) and vr04 (child override of the origin).
- vr06 (64-bit 64'd18446744073709551615): uhdm-cmp 60 → 64 lines with the head moved LATER. The cont_assign read is now golden's DEC. The parameter value is now golden's INT:0. The decompile reads 18446744073709551615 where golden writes 0, the same face the origin parameter PA already had on pristine. Referenced-tree distance 90 → 42.
- vr07 (an interface and a child): NOT_EQUAL → STRICT_NOTEQUAL fullname. The interface reference reads work@ifc where golden has work@top.i, which is pass 473's MC/mc10 face on the sister's ground.
- vr08 (`PB = a::PA`) is byte-identical.

**§ addOperandConstMint475 (VA)**
- STRICT_EQUAL on the law: va02, va06 (an enum member and a cast beside a 'd literal), va07 (a grandchild) and va08 (a 'd default overridden by hex and a hex default overridden by 'd).
- Unchanged STRICT_EQUAL controls: va01 (plain-decimal origin and hex operand stay UINT), va03 and va09.
- va04 (6'd63 + 6'd1): golden reads INT:64 at size 6 and ours INT:0. The overflow is not truncated in golden.
- va05: a generate-block localparam, golden INT:35. This is AM/am08's face.

**§ refChainHexWrittenCase475 (VH)**
- vh01 (`8'hAb` mixed case) reaches STRICT_EQUAL.
- vh03 and vh04 are byte-identical controls.
- vh02 (`16'hx_ab`): the HEX case is now golden's. Its head is the read of a referenced parameter holding x digits, which golden folds and ours leaves a ref_obj (pristine too).

**§ pkgQualCaReadValueForm475 (VQ)**
- STRICT_EQUAL on the law: vq01 (a child and an uninstantiated module), vq02 (a reference chain and 6'sd5), vq04 (32'd4294967295 and an interface), vq05 (an explicit import beside a qualified read) and vq06 (narrower and wider left sides, untyped 'd9).
- vq03: the parenthesized read converts. The generate-block `assign z = p::P` stays a ref_obj where golden folds to INT:33 (pristine too, head later).

**§ elabRhsSharesDefParamChain475 (VT)**
- vt01 (two child modules plus the top): STRICT_NOTEQUAL fullname → STRICT_EQUAL.
- vt02 (one child under two parents) stays STRICT_EQUAL with its bytes moved.
- vt03 (an interface inside a child) stays STRICT_NOTEQUAL fullname on the interface reference name (the sister's).
- vt04 (two packages each importing a) is byte-identical at 322 lines. Its head is package c's listing, an older face.

## Away census (evidence/away_census.txt, away_movers.txt, away_tree_dd.txt)
The census covers 8845 case dirs under tools/probe/r11u4?? and v11u4?? (passes 400 to 473 plus 468's), with the path list built and fence-filtered before any file was opened.

- No exit code moves. 8684 exit-0 dirs and 38 exit-4 dirs are byte-identical.
- The 56 exit-3 movers also differ between two pristine runs.
- The 67 exit-0 movers are the implementer's 67:
  - 17 reach STRICT_EQUAL: r11u471 EX/ex07, TF/tf07, tf09; r11u473 MC/mc06, PO/po03; v11u409 VW/vw01; v11u411 VE/ve08; v11u467 VU/vu10; v11u469 VM/vm01, VT/vt08, vt14; v11u471 VI/vi05, vi08; v11u473 VA/va04, va10, VC/vc02, VX/vx01.
  - v11u409 VW/vw07 and v11u423 VC/vc09 go 64 → 17 lines with the head later.
  - The rest keep their verdict. No strict verdict leaves STRICT_EQUAL.
  - On the referenced tree, 24 are closer, 43 the same and **0 away**.
  - The whole-dump distance grows on 20 dirs (r11u409 IM/im16 189 → 281, v11u473 VC/vc08 340 → 400 and others). It grows **only inside the weaklyReferenced section**, which neither judge nor the plugin reads.

## Finding (not a break): the shared chain's IDENTITY
evidence/tools/idchk.cpp checks, for every module param_assign Rhs constant, whether its typespec hop 1 and hop 2 are the same object as the Lhs's own chain, the definition listing's Lhs chain, or a fresh clone. It was run on 144 case dirs (evidence/identity_census.txt).

- Golden's elaborated Rhs shares the DEFINITION listing's Lhs typespec objects (h1=def h2=def on NT/nt01 and IM/im16).
- Pristine writes fresh clones.
- § elabRhsSharesDefParamChain475 writes golden's NAME (work@sub.PB.t) but not its identity. Its memo gives a fresh clone named after the definition (nt01), or, in a top module where the definition and instance names coincide, the elaborated Lhs's own clone (im16 h1=own). That is why im16's weaklyReferenced tail drops from 70 to 58 ft_t copies against golden's 89.
- The mismatch count against golden is equal on pristine and law in all 144 dirs. Typespec identity is the comparator's explicit canonicalised residue, and downstream stays 803 IDENTICAL.
- The law's comment, "shares the definition copy's chain", overstates what it writes. The decoded rule would point the elaborated Rhs's ref_typespec at the definition listing's Lhs typespec itself.

## Goal 1 (re-measured)
- All 75 SURELOG_ONLY rows carry an upstream slang `error:` diagnostic; none carries the exporter's own message.
- v11u413 VI/vi06 (u.mk(x).a[2]) and VC/vc04 (C::mk().arr[1]) exit 4 on both binaries, and v11u415 VT/vt03 (this.mk().inner.s) exits 0. Upstream slang accepts all three (evidence/goal1_probe_faces.txt).
- bp_unicore alone with the size guard on: law rc 3 in 16.8 s at 837 MB. The guard stays.

## Residues, ranked (all wrong on pristine too; none moved away)
1. A qualified or unqualified package-parameter operand inside an operation the XOR law keeps: golden folds it to the respelled INT form (VX/vx11).
2. A generate-block qualified read `assign z = p::P` (VQ/vq03) and a generate-block localparam add (VA/va05, AM/am08). Golden folds both to INT; ours keeps a ref_obj or UINT.
3. An add that overflows its declared width: golden keeps INT:64 at size 6, ours INT:0 (VA/va04).
4. A 64-bit decimal reached by reference: golden's decompile is 0, ours the digits. The origin parameter already shows this face on pristine (VR/vr06).
5. A referenced parameter holding x digits: golden folds the read, ours leaves a ref_obj (VH/vh02).
6. The elaborated Rhs typespec identity (the finding above).
7. The implementer's ranked residues (QR/qr_i, qr01, VC/vc10, qr_o, AM/am03, RC/rc01, the `PB + 6'd1` continuous-assignment fold, the XK nested and other-context XOR shapes, v11u473 va02, vd04 and vd07, AM/am07 and am08) all stand as reported. VT/vt04's package c listing and VR/vr08 are older faces.

## Sister-ground faces (reported, not written)
- The interface reference full name, work@ifc where golden has work@top.i (VR/vr07, VT/vt03; pass 473's MC/mc10; ModuleEmit's interface listing).
- The implementer's three faces stand: ModuleEmit's elaborated whole-right-side own copy of a UINT constant (QR/qr_o), ModuleEmit's variable-initializer branch (RC/rc02, IA/ia12), and the interface reference full name.

## Process
- One law build, one five-stage sweep and no pristine build or sweep.
- Each launch was preceded by a check for live sweeps or runners, and nothing overlapped.
- The case runs and the away census ran after the sweep, three single-process workers.
- The fence list was read into a file by a program without printing it, and every tree-wide list was filtered on it first. Every csv copy in evidence/sweep is fence-filtered (row counts in evidence/sweep/README_rows.txt).
- No other agent's process was touched.

## Drivers
- drivers/runcase.sh: Surelog golden with check_probe.py's flags; prints rc, uhdm-cmp lines, strict verdict and dump distance.
- drivers/swcheck.sh: switch check.
- drivers/awaybytes.sh: away census.
- evidence/tools/idchk.cpp: identity census.
