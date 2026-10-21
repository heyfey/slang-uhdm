# v11u428 — adversarial verification of r11u428 (module/type ground, pass 428)

Base 04c3f6f4d.  Implementer's patch /tmp/r11u428.patch (applies clean).  This
verifier's patch /tmp/r11u428.verified.patch = the implementer's patch plus two
production refinements (src/TypeEmit.cpp, src/ModuleEmit.cpp), this directory
and tests/LAWS.md regenerated.

VERDICT: the implementer's numbers reproduce exactly.  The pass had TWO BREAKS
on legal SV, where pristine was right and the law was wrong.  Both are fixed
behind their own switches.  The fixes move no corpus row, no probe case and no
sv-tests status.

## Binaries (frozen before any measurement)

| name | path | md5 |
|---|---|---|
| pristine | /tmp/v11u428_bin/pristine (copy of the main tree's build/slang-uhdm at the base) | 4cfe02b16eea0da34c20cac5afcbd2a7 |
| law | /tmp/v11u428_bin/law (rebuilt once in /tmp/wt_v11u428 from /tmp/r11u428.patch) | 51d6ad0ed34867e09399940fe7adf8ff (= the implementer's law17) |
| verified | /tmp/v11u428_bin/ver2 | 5fb9410cbc9dc985093da66a87a6570c |

ver1 (e3ab8c51...) was an intermediate build.  Its type-parameter check never
fired, because slang resolves the name to a TypeAlias.  It was used only on case
runs and was never swept.  The budget was kept to one law build, one verified
build and one sweep on each of the two.  Both binaries report slang
12.0.0+545f88b2e.

No pristine build and no pristine sweep were made.  The pristine reading is the
master's control sweep /tmp/intr11u426.

## Gates (drivers/fullsweep.sh: corpus stages from the worktree, sv-tests through the main tree's scripts/check_svtests.py read-only, baseline the base's results/golden_svtests.csv)

| stage | law (/tmp/v11u428sw1) | verified (/tmp/v11u428sw2) |
|---|---|---|
| probe | 0/0/0, csv identical to the control | 0/0/0, csv identical to law |
| surelog | 0/0/0, csv = control except the two LowMem log-path texts | same |
| uhdm2rtlil | 0/0/0, csv identical | same |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, csv identical | same |
| sv-tests | regressions=0 conversions=10 changes=0 | regressions=0 conversions=10 changes=0 |

- **sv-tests counts (both sweeps):** EQUAL 1889, STRICT_NOTEQUAL 6, DIFFERENT 45, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, of 2346.
- **csv agreement:** the law sweep's sv-tests csv is byte-identical to the implementer's /tmp/r11u428sw2/svtests.csv. The verified csv is byte-identical to the law csv.
- **The 10 conversions are exactly the implementer's rows:**
  - bsg_cache_non_blocking_data_mem, bsg_imod_range, bsg_nonsynth_axi_mem, p489, p599 and p765 go DIFFERENT -> EQUAL.
  - testbenches uvm_agent_active, uvm_agent_passive, uvm_driver_sequencer_env and uvm_monitor_env go DIFFERENT -> STRICT_NOTEQUAL `differ:type(1)`.
- **byteverify** (r11v75repro/byteverify.sh, SELFCHECK=1, per corpus): 0 of 962, 0 of 1608 and 0 of 805 movers in each of three runs: law against the control, verified against the control, and verified against law. The self-check flagged every file but the fixed one each time.
- **The sv-tests kept databases, verified against law:**
  - 72 of them differ by bytes.
  - On 71 of them, including uvm_test_init where the refinement's check logs, a dump with the workdir name normalized reads 0 diff lines. They differ only by the embedded workdir path (sw1 against sw2).
  - The 72nd, tnoc, did not finish dumping within the 900 s timeout, as with earlier verifiers. The refinement's trace does not fire on tnoc.
  - The sv-tests csvs are identical.
- **Canaries:** ok=52 and ok=16 on both sweeps; ctcan2 PASS for surelog and uhdm2rtlil on both.
- **Binary audit**, fence-filtered over 5659 cmds.txt per sweep: 5609 name the sweep's binary. The other 50 hold only a Surelog line, from the surelog corpus.
- **Trace census, law sweep:** 16 sv-tests databases fire, and no corpus row or probe case does. They are the 10 conversions plus bsg_comm_link, easyUVM, the 3 scoreboard testbench rows and rsd. The implementer's report says 17; its own list adds up to 16.

## The breaks (pristine right, law wrong) and the refinements

1. **§ clsLocalTypeParamArgBare428v** (`R11V428_TPARGBARE_OFF`, TypeEmit, inside § clsMethodLocalForeignPkgSpec428).
   - **Rule:** a specialization whose argument names a TYPE PARAMETER of the enclosing class stays bare in golden. Example: `box #(U) b;` in a method of `class B #(type U = int)`.
   - **Why:** Surelog compiles the generic class's method once, with U unresolved. slang elaborates the method per specialization, and resolves U to a TypeAlias owned by the specialization's ClassType.
   - **What the law broke:**
     - VK/vk15 went STRICT_EQUAL -> NOT_EQUAL (77 uhdm-cmp lines: `LHS: <null>` against our listing).
     - VK/vk21 went STRICT_NOTEQUAL fullname -> NOT_EQUAL.
     - VK/vk22 moved away, dump distance 27 -> 28.
   - **With the refinement:** vk15 and vk21 are back at pristine's bytes, and vk22 reads STRICT_EQUAL (`box #(int)` keeps its listing, `box #(U)` is bare).
   - **Controls that keep the listing:** a value parameter `logic [N-1:0]` (vk20) and `box #(int)` inside a generic class (vk19).
   - **Trace note:** the trace logs every type-parameter argument the check sees at a foreign-generic site. That includes same-package sites where the law would not fire anyway, which is why the verified trace lists the UVM rows and the five corpus UVM rows. byteverify verified-against-law reads 0 on every corpus, and 0 on 71 of the 72 kept sv-tests dumps after normalization.
2. **§ uninstGrCaExplicitTopOnly428v** (`R11V428_GRCATOP_OFF`, ModuleEmit, inside § uninstDefGenRegionCaUnlisted428).
   - **Rule:** the law applies only under an explicit --top.
   - **Why:** with no --top, Surelog elaborates every uninstantiated module as a top, including one with a default-less parameter, and keeps the region's assignment at module level.
   - **What the law broke:** VG/vg09 (no TOP, `module m #(parameter W)`, golden lists two module-level cont_assigns at 7:12). The law dropped them; dump distance 350 -> 370.
   - **With the refinement:** vg09 is back at pristine's bytes. bsg_imod_range (top_module: top) still converts.

**Switches.** R11V428_OFF gives the law's bytes on all 86 attack cases and on the implementer's 59. Each fix's own switch gives the law's bytes on its own cases (vk15, vk21, vk22 and vg09). R11U428_OFF still drops the whole pass.

## Reproduction of the implementer's grid (evidence/impl_grid_reproduced.txt)

- **Lines:** 59 of 59 match after normalization (exit code, uhdm-cmp count, strict verdict, both switch columns). The md5s differ only by the worktree path.
- **Readings:**
  - 44 law STRICT_EQUAL, 2 STRICT_NOTEQUAL, 13 NOT_EQUAL.
  - R11U428_OFF restores pristine on 59 of 59.
  - The own switch restores pristine on 51; the other 8 need a co-firing switch, as the implementer reported.
- **Verified against law:** byte-identical on all 59.

## Attack grid (evidence/attack_grid.txt; 86 fresh case dirs in VE, VF, VG, VH, VI, VK, VS)

Every case is accepted by upstream slang (~/.local/bin/slang, --single-unit), and every exit code is 0 on all three binaries.

| pristine -> verified | cases |
|---|---|
| NOT_EQUAL -> STRICT_EQUAL | 49 (vk22 through the refinement) |
| NOT_EQUAL -> STRICT_NOTEQUAL type | 2 (VS/vs13 `$countones(P)`, vs16 `$rtoi(2.5)`) |
| STRICT_EQUAL and STRICT_NOTEQUAL controls kept | 6 (VF/vf12, VG/vg03, vg05, vg08, VK/vk15, vk21) |
| NOT_EQUAL on both | 29 |

**The 29 NOT_EQUAL-on-both cases.**
- **Toward golden by sorted-dump distance:** VE/ve05 and ve06, VF/vf08 and vf13, VG/vg02 and vg10, VI/vi01–vi04, VK/vk16, vk18 and vk23.
- **At pristine's distance:** VF/vf10, VG/vg06 and vg07, VH/vh04, vh07 and vh08, VK/vk01–04, vk06 and vk08, VS/vs17, vs18 and vs19. Of these, vh04, vh07 and vh08 have moved bytes at an equal distance (see residue 6); the rest are byte-identical.
- **vg09:** back at pristine through the refinement.

**Dump distance on strict-equal cases.** VS/vs08, vs09 and vs20 read STRICT_EQUAL with uhdm-cmp at 0, yet their sorted-dump distance grows (38->44, 34->40, 28->32). Ours prints the shared call cells in full where golden prints them once. The judge and the strict walk both read equal, and downstream is IDENTICAL.

**Downstream** (evidence/downstream_attack1.txt and downstream_attack2.txt, 66 class-free cases on pristine and law): none worse. VF/vf03 STATUS_DIFF -> IDENTICAL, vf05 DIVERGENT -> IDENTICAL, vf11 DIVERGENT -> IDENTICAL. The refinements touch no class-free case except vg09, which is at pristine's bytes.

## Earlier-pass census (evidence/earlier_pass_census.txt, earlier_pass_movers.txt)

- **Scope:** 3424 fence-filtered case dirs of tools/probe/{r,v}11u4NNrepro present at the base, run on pristine, law and verified.
- **Unchanged:** 3413 byte-identical on all three. Verified equals law on all 3424.
- **11 movers, all toward golden:**
  - **To STRICT_EQUAL:** r11u415 FJ/fj01, fj02; v11u415 VX/vx04; r11u417 HP/hp01 (pass 417's '* *' residue); r11u424 ND/nd01.
  - **To STRICT_NOTEQUAL:** r11u424 ND/nd02 (depth); v11u405 VU/vu02 (type).
  - **Closer:** r11u405 UB/ub03 (42->35); v11u415 VX/vx02, vx03, vx05 (38->28, 62->52, 38->28; head later).

## Residues (wrong on pristine too, none moved away after the refinements), ranked

1. **The 4 testbenches rows at `differ:type(1)`:** the implementer's radix-enum face, where the cast's enum typespec reaches the definition listing (ExprEmit; sister ground).
2. **A scoped specialization `p::box #(byte) b;` as a class-method local:** golden names the class_typespec `p::box` with no parameters; ours writes `p::box #(byte)` (VK/vk01–04, vk06, vk08; uhdm-cmp 24 on both binaries). The law does not reach the scoped spelling.
3. **A class-scope typedef as the specialization argument (VK/vk16):** golden clones the alias as it does for a package typedef; § clsMethodLocalForeignPkgSpec428 clones package typedefs only. 77 -> 17 lines.
4. **Fork-block locals (VK/vk18):** the head moved later, uhdm-cmp 77 -> 210, distance 73 -> 5.
5. **Generate regions whose first item is a continuous assignment** (VG/vg02, vg10; the implementer's GR residue). An interface region (vg06) and a module reached only from an uninstantiated module (vg07) are not reached.
6. **§ hpMacroSelDispExpanded428's synDisp428 drops a CALL's parentheses** (VH/vh04: golden `p.data[$clog2(8) + 1 * i+:4]`, ours `$clog28 + 1 * i`; vh08 `$clog24` against golden's folded `p.sel[0+:2]`). A function call in the select renders `fi` where golden renders the call empty, `p.data[+:4]` (vh07). The pristine spelling was wrong too, at the same distance. The fix is to keep an argument list's parentheses in synDisp428.
7. **Interface-method implementation (VI):**
   - A module array in a generate loop (vi01), a function before the last task (vi02), an automatic task (vi03) and a call from top (vi04) all move toward golden.
   - The remaining head is the nameless task's elaborated listing.
8. **Follower shapes not reached:** a `[3:0] b` follower (vf10), a `logic signed` leader (vf08, 3 lines left), and a `wire c` after the chain (vf13, toward).
9. **Whole-right-side system calls not reached:** a generate block (vs17, vs19), a concatenation left side (vs18), and a call over a parameter or literal at STRICT_NOTEQUAL type (vs13, vs16).
10. **Case equality with a signed one-bit literal `1'sbx` (VE/ve06) and `1'Bx` (ve05):** toward golden, not equal.

## Sister-ground faces (reported, not written)

None new beyond the implementer's:
- ExprEmit's generate-block `$bits`.
- ExprEmit's `spaceOps` `**`.
- ExprEmit's cast enum copy.
- ParamEmit's p130 type parameter.

## Process

- **Fence:** the fence list was read into a file by a program, never printed; every tree-wide list was filtered on it before a file was opened. No other agent's process was touched.
- **Sweeps:** both sweeps were launched only after two quiet readings. The master's pass 425 integration sweep was live at first; the sweeps waited for it to end.
- **Slip 1:** the first waiter's pgrep matched its own command line. It was stopped by its own task id, and a bracketed-pattern script replaced it.
- **Slip 2:** one batch of the earlier-pass mover check was given a wrong relative path. The case runner then ran Surelog in a scratch golden directory against `ls /*` and copied nothing. The junk scratch directories were deleted, and run1.sh now refuses a missing case dir. Main tree and worktree were clean afterwards.
- **Census paths:** the census list was built from the main tree's tools/probe, which by then held the newly landed r11u425repro. Those dirs are absent at the base, so they were skipped; the 3424 counted are the ones present in the worktree.
