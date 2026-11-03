# v11u473 — adversarial verification of r11u473 (§ modImpCopyTdChainHomeTop473)

Base 01d7233b (pass 471). Implementer's patch `/tmp/r11u473.patch` (md5 0e346172dc5e4f46a0a792c7d07533cf). It applies clean on a fresh 01d7233b.

**Verdict: CONFIRMED with no production change.** The verified patch's src diff is byte-identical to the implementer's. No break was found: no case dir, corpus row, probe case, downstream row or sv-tests row moves away from golden.

## Binaries (frozen, chmod 555)
- pristine: `/tmp/v11u473_bin/pristine`, md5 1c8052676adb70d4a65475f27607fafe. A copy of the main tree's build/slang-uhdm, which is what the budget allows. No pristine build and no pristine sweep: the pristine reading is the master's control `/tmp/intr11u471`.
- law: `/tmp/v11u473_bin/law`, md5 afa30e9d601c11d257df9155230c42ca. Rebuilt once from the patch in /tmp/wt_v11u473 (-j 2). It equals the implementer's law6 and links slang 12.0.0+545f88b2e.
- There was no verified build, because nothing changed.

## The implementer's grid, reproduced (evidence/impl_grid_repro.txt)
The 22 dirs (MC 16, PO 6) were run on pristine, law, law with `R11U473_OFF=1` and law with `R11U473_MODCOPYTD_OFF=1`.
- Every exit code is 0, and every uhdm-cmp count and strict verdict equals the implementer's grid_law6.txt.
- Both switches give pristine's bytes on 22 of 22.

## Attack grid (cases/VA, VC, VD, VS, VX: 40 dirs; evidence/grid.txt)
Every case names § modImpCopyTdChainHomeTop473 in its first line. Upstream slang (`~/.local/bin/slang -q dut.sv --single-unit`) accepts every one; the real exit code was read.
- Three first drafts that upstream rejected were rewritten before any run: va07 (`8'0`), vc01 (`export b::*` with PB not referenced in c) and vc08 (a `$unit` typedef read from a package). One more, VD/vd05 (PB in a port range before the import), was deleted.
- Every exit code is 0 on both binaries.
- Columns: uhdm-cmp lines and strict verdict, pristine -> law, then golden line overlap (drivers/overlap.py) and the multiset dump distance to golden as missing/extra lines (drivers/msdist.py, header line dropped).

| case | shape | pristine | law | overlap |
|---|---|---|---|---|
| VA/va01 | generate block `assign y = PB` | 112 | STRICT_EQUAL | 657 -> 828 of 831 |
| VA/va02 | module function `return PB` | 112 | 17, head later (golden's typespec on the return fold, ours none; older face) | 685 -> 914 |
| VA/va03 | package c `localparam int X = PB + 1` | 340 | 340, closer | 956 -> 1152 |
| VA/va04 | two instances of a child, `PB + 1` | 112 | STRICT_NOTEQUAL fullname(2) | 1105 -> 1303 |
| VA/va05 | program `initial y = PB` | 112 | 502, head later (golden lists `a::t` in the program's typedef listing, ours nothing; ModuleEmit, the mc03 family) | 697 -> 836 |
| VA/va06 | instantiated interface `logic [3:0] v = PB` | 112 | 17, head later (interface variable-initializer fold has no typespec in ours; ModuleEmit) | 688 -> 883 |
| VA/va07 | ternary with a concatenation `{PB, PB}` | 112 | STRICT_EQUAL | 881 -> 1136 |
| VA/va08 | class method in package c `return PB` | 242 | 242, closer | 891 -> 1087 |
| VA/va09 | module own `parameter t MP = PB`, imports a and b | 112 | STRICT_EQUAL | 770 -> 933 |
| VA/va10 | leaf two levels down, `logic w = PB` | 112 | STRICT_NOTEQUAL fullname(1) | 1037 -> 1209 |
| VC/vc01 | three levels with `export b::*` in c | 436 | 436, closer | 1358 -> 1719 |
| VC/vc02 | b `export a::*`, `PB ^ MP` | 112 | 68, head later (operation kept by golden, the mc06 face) | 787 -> 1013 |
| VC/vc03 | packed struct typedef | 46 | byte-identical (abstains: the head is earlier) | 815 = 815 |
| VC/vc04 | two importer packages b1, b2 | 214 | 214, closer | 1021 -> 1363 |
| VC/vc05 | `typedef int t`, PB = -3 | 48 | 48, closer | 369 -> 403 |
| VC/vc06 | typedef range from a's parameter | 58 | 58, closer | 990 -> 1200 |
| VC/vc07 | child default `b::PB`, override `PB + 1` | 112 | 112, head later (override actual, the mc16 face) | 1155 -> 1351 |
| VC/vc08 | typedef homed in z, re-exported by a | 312 | 312, closer | 1162 -> 1612 |
| VC/vc09 | a third package d also lists t | 214 | 214, closer | 826 -> 1027 |
| VC/vc10 | qualified `b::PB` without import | 17 | 17, closer (golden has no typespec on the qualified fold, ours keeps one; it is now a fresh clone) | 408 -> 410 |
| VC/vc11 | `localparam t LB = 8'h3c`, var init and `w & LB` | 112 | 64, head later | 815 -> 1043 |
| VC/vc12 | module imports b then a | 112 | STRICT_EQUAL | 673 -> 874 |
| VD/vd01 | packed 2-D typedef | 192 | STRICT_EQUAL | 841 -> 1178 |
| VD/vd02 | `bit signed [7:0]`, PB = -5 | 88 | 88, closer | 550 -> 662 |
| VD/vd03 | CONTROL enum typedef | STRICT_EQUAL | byte-identical | 619 = 619 |
| VD/vd04 | function argument `inc(PB)` | 112 | 17, head later | 706 -> 849 |
| VD/vd06 | `$unit` import of b plus module import of a, `t w = PB` | 112 | STRICT_EQUAL | 985 -> 1369 |
| VD/vd07 | `localparam int L = PB * 2`, `{2{PB}} ^ L` | 112 | 17, head later | 740 -> 967 |
| VS/vs01 | CONTROL module own parameter of an imported typedef | STRICT_EQUAL | byte-identical | 825 = 825 |
| VS/vs02 | CONTROL-shape own parameter plus b imported, var init | 112 | STRICT_EQUAL | 1843 -> 2070 |
| VS/vs03 | own parameter of a typedef re-exported by c | 112 | STRICT_EQUAL | 2100 -> 2296 |
| VS/vs04 | CONTROL interface own parameter | 31 | byte-identical | 909 = 909 |
| VS/vs05 | CONTROL home PA read in a nested instance | STRICT_NOTEQUAL fullname | byte-identical | 1467 = 1467 |
| VS/vs06 | net declaration `wire [3:0] w = PB` | 112 | STRICT_EQUAL | 1483 -> 1710 |
| VS/vs07 | always_ff case item `PB:` | 112 | 112, closer | 1638 -> 1894 |
| VS/vs08 | two top modules importing b | 112 | STRICT_EQUAL | 2084 -> 2568 |
| VS/vs09 | nested child `assign y = PB` | 112 | STRICT_EQUAL | 1590 -> 1843 |
| VS/vs10 | nested child under a generate block, var init | 112 | 112, closer | 1636 -> 1748 |
| VX/vx01 | one child instance, `PB + 1` | 112 | STRICT_NOTEQUAL fullname(1) | 816 -> 986 |
| VX/vx02 | two child instances, `assign y = PB` | 112 | STRICT_EQUAL | 1908 -> 2273 |

Tally:
- STRICT_EQUAL on law: 14, of which 12 are new (vd03 and vs01 are controls equal on both binaries).
- NOT_EQUAL -> STRICT_NOTEQUAL fullname: 3 (va04, va10, vx01).
- Byte-identical: 5 (vc03, vd03, vs01, vs04, vs05).
- Every other mover is closer by golden line overlap, and the missing-line count falls on every mover.
- **No dir has a lower overlap on law than on pristine, and no exit code moves.**
- Switches: `R11U473_OFF=1` and `R11U473_MODCOPYTD_OFF=1` each give pristine's bytes on 40 of 40.

**Downstream** (scripts/downstream_uhdm2rtlil.py `one`, the case machinery): va01, va04, va07, va10, vc04, vc11, vc12, vs02, vs06, vs07, vs08 and vs09 read IDENTICAL on both binaries.

**The extra-line column grows on several STRICT_EQUAL movers** (va01 11 -> 62). Every such line was traced to the `\_weaklyReferenced` tail of the dump: the law's fresh clones, more objects than golden's, are listed there. Neither judge reads that tail, and neither does the plugin. It is a byte-hygiene residue, the same kind as pass 465's unreferenced placeholder.

## Away census (evidence/away_bytecmp.txt, away_dirs.txt; drivers/bytecmp.sh)
The census covered 2210 fence-filtered case dirs: the implementer's 394, plus every dir of passes 400 to 479, r11u118, r11v11u118 and r11u119 whose dut.sv uses `import`. Each was run on pristine and law with the probe flags.
- **No exit code moves.**
- 33 dirs differ in bytes:
  - **The implementer's 8:**
    - ia04, ir08 and v11u471 VT/vt04 reach STRICT_EQUAL;
    - ex07, VT/vt14, VM/vm01, VT/vt08 and VI/vi06 are closer at the same or a lower uhdm-cmp count.
  - **Its own 14 MC dirs.**
  - **4 found newly:**
    - v11u408 VU/vu04: 112 -> STRICT_EQUAL;
    - v11u464 VT/vt09: 112 -> STRICT_EQUAL;
    - r11u409 IM/im16: 84 -> 84, golden overlap 588 -> 978;
    - v11u409 VI/vi12: 84 -> 84, golden overlap 1907 -> 2331.
  - **7 exit-3 dirs** (r11u440 MS/ms06, r11u459 FT/ft13 and ft14, v11u454 VL/vl14 to vl16, v11u464 VT/vt13 and VF/vf10). They differ between two pristine runs as well (checked on five of them), which is the known exit-3 variance.

## The one sweep on the law binary (workdir /tmp/v11u473_sw, `R11U473_TRACE` on)
- **Launch:** drivers/v11u473_launch.sh waited for three quiet readings 60 s apart. It held while the sister v11u468's two sweeps ran, and started at 20:15:41.
- **Corpus stages:** the four corpus stages ran from the worktree.
- **sv-tests stage:** it ran through the main tree's tests/sweep.sh, because the worktree's UVM folder is empty.
- **Exit codes:** both commands exited 1 on the stale law index alone. In the worktree this is from this verifier's new case files; in the main tree, as in the implementer's run.

| stage | result | csv vs /tmp/intr11u471 (path-normalized) |
|---|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0 | identical |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | identical |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 of 871 | identical |
| svtests | EQUAL 1932, DIFFERENT 8, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; 0/0/0 | identical |

- **byteverify** (SELFCHECK=1, against the control; evidence/byteverify.txt): 0 of 962, 0 of 1608 and 0 of 805. The self-checks flag 961, 1607 and 804.
- **probe** (evidence/probe_pdump.txt): 4087 of 4087 SAME by path-normalized dump, and the negative control reads DIFF.
- **sv-tests kept databases:** all 29 differ from the control in raw bytes, and all 29 read STRICT_EQUAL under `uhdm-strictcmp --no-canon` (serialization variance).
- **trace:** 0 files, which is the implementer's predicted zero.
- **Canaries** (evidence/canaries.txt): ok=52 and ok=16, ctcan2 PASS (EXPECT_UNKNOWN=1) and PASS (EXPECT_UNKNOWN=6).
- **Binary audit**, fence-filtered (evidence/binary_audit.txt):
  - surelog: 1523 of 1573 records name the law binary; the other 50 hold only a Surelog line. Two of those 50 matched the audit's first heuristic through the UVM path and were checked by hand.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.

## Goal 1, reproduced
- **SURELOG_ONLY rows:** all 75 carry an upstream slang `error:`, and none carries the exporter's unsupported message. No BOTH_REJECT row carries it either.
- **The probe faces on law:**

  | face | case | ours | upstream slang |
  |---|---|---|---|
  | C::mk().arr[1] | v11u413 VC/vc04 | 4 | 0 |
  | u.mk(x).a[2] | v11u413 VI/vi06 | 4 | 0 |
  | this.mk().inner.s | v11u415 VT/vt03 | 0 | 0 |

- **bp_unicore** alone through the runner on law, on a quiet machine: Surelog crashes (rc -11). Ours exits 3 in 13.7 s at 835 MB maximum child RSS. The guard stays.

## Residues (ranked; all wrong on pristine too, none moved away)
1. **The elaborated param_assign Rhs alias full name** in a non-top instance, where the child reads PB inside an operation (VX/vx01, VA/va04) or two levels down (VA/va10).
   - Golden names the alias reference after the definition copy's parameter: `work@sub.PB.t`, `work@leaf.PB.t`.
   - The law names it after the role reference: `work@top.u1.t`.
   - At top level (MC/mc14) and for a whole-right-side read in a child (VS/vs09, VX/vx02), the law's name is golden's.
   - Not decoded. It is a candidate refinement for the law's naming line, `rfn + "." + bare`.
2. **The implementer's face 2:** the INT respell of `PC = PA` / `PA + 1` in the elaborated module copy (ex07, vt14, vm01).
3. **Folds the law does not reach.** In each, golden carries a typespec that ours lacks, or golden carries none where ours keeps one:
   - a function return (va02);
   - an interface variable initializer (va06);
   - a function argument (vd04);
   - a localparam and a replication (vd07);
   - a qualified `b::PB` (vc10, where golden has no typespec).
4. **Package contexts that read PB** (a package localparam va03, a package class va08, chains vc01, vc08). These are closer, but still differ at the package import-copy roles (the rolecmp count is unchanged at 6 / 12).
5. **Listing faces on the sister's ground:**
   - the program's typedef listing (va05);
   - an override or port actual (vc07, the implementer's mc16 face);
   - a generate-nested child (vs10);
   - a case item in a process (vs07).
6. **Byte hygiene:** the law's clones exceed golden's count in the `\_weaklyReferenced` dump tail. Neither judge reads that tail.
7. **The implementer's residues 3 to 8** stand as written.

## Sister-ground faces (reported, not written)
- **The program's typedef listing** (VA/va05): golden lists `a::t` Instanced at b in work@prg's typedef listing. This is ModuleEmit, the same family as the implementer's mc03.
- **The instantiated interface's variable-initializer fold** (VA/va06): ours carries no typespec, golden does. This is ModuleEmit's variable-initializer branch, the implementer's face 3.

## Process
- **Budget:** one law build, no pristine build, no verified build, one five-stage sweep, one byteverify, one probe dump census, one away byte census, and one bp_unicore run.
- **Concurrency:** the case runs and the byte census ran as single processes while the sister's sweep was live. No sweep or runner batch of this verifier overlapped another.
- **Fence:** the fence list was read into a file by a program and never printed. Every tree-wide list was filtered on it before any file was opened. No fenced test was named, opened or run.
- No other agent's process was touched.
