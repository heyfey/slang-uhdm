# r11u127: the LAW file of every unresolved gate case

Base `27a53a02`. This is a maintenance pass. It touches no production file, no
case source and no script. The only writes are `LAW` files under `tests/probe/`
and this README. A `LAW` file holds one law name per line. Every name written
here was checked against the laws in `tests/LAWS.md` section 1.

At the base, the index listed 102 gate cases with a `?` and 213 tied to no law
(section 3). All 315 were checked, pass by pass. 197 now have a `LAW` file. The
other 118 have none, and each one's reason is given below. No law was assigned
by guess.

## Counts, before and after (`scripts/law_index.py` run in the worktree)

| | at 27a53a02 | after |
|---|---|---|
| cases in the gate | 4087 | 4087 |
| tied to one law | 3772 | 3969 |
| listed with `?` under several laws | 102 | 98 |
| tied to no law (section 3) | 213 | 20 |
| laws with cases in the gate | 563 | 608 |

`tests/LAWS.md` itself is not shipped. The master regenerates it.

## How a case was resolved

The sources were used in the order the brief gives:

1. The pass README's grid table or prose naming the case.
2. The pass's generator and evidence scripts.
3. The case's own text, compared with the law's `§` comment in the source.
4. The landing commit message.

Only the pass's own laws were written. A control case takes the law of the grid
row or section that holds it. A case that exercises several of the pass's laws
lists each one. A verification pass's cases take the laws of the pass that its
title names.

Several of the passes below have a plain `README` file with no extension:
`r10earl_repro`, `r10rggen6/7/8/9repro`, `r10imex_repro` and `r10itype_repro`.
The index reads only `README.md` and `README.txt`, so it reported these passes
as having no README. Each such file maps its witnesses to `§` laws, and it was
used as source (1).

## Per pass

`?` and `none` are the counts at the base. `LAW` is the number of LAW files
written, and `left` is the number of cases still without one.

| pass | ? | none | LAW | left |
|---|---|---|---|---|
| r10earl_repro | 0 | 41 | 34 | 7 |
| r11u15repro | 0 | 40 | 40 | 0 |
| r11u108repro | 39 | 0 | 1 | 38 |
| r10rgg3repro | 0 | 35 | 35 | 0 |
| r10sd10repro | 27 | 0 | 0 | 27 |
| r10vrgg3repro | 0 | 24 | 24 | 0 |
| r11vu15repro | 0 | 22 | 22 | 0 |
| r11u88repro | 13 | 0 | 0 | 13 |
| r10rggen7repro | 0 | 9 | 9 | 0 |
| r11u112repro | 9 | 0 | 0 | 9 |
| r10imex_repro | 0 | 7 | 6 | 1 |
| r11u14repro | 0 | 6 | 6 | 0 |
| r10uvm49repro | 0 | 5 | 0 | 5 |
| r11u17repro | 4 | 0 | 0 | 4 |
| r11u51repro | 0 | 4 | 0 | 4 |
| r10fiot_repro | 3 | 0 | 3 | 0 |
| r10itype_repro | 0 | 3 | 3 | 0 |
| r10rggen6repro | 0 | 3 | 3 | 0 |
| r11u107repro | 3 | 0 | 0 | 3 |
| r11u11repro | 0 | 3 | 3 | 0 |
| r10uvm8repro | 0 | 2 | 0 | 2 |
| r11u10repro | 0 | 2 | 2 | 0 |
| r11u3repro | 0 | 2 | 2 | 0 |
| r11u99repro | 2 | 0 | 0 | 2 |
| r10rggen8repro | 0 | 1 | 1 | 0 |
| r10rggen9repro | 0 | 1 | 1 | 0 |
| r11u111repro | 1 | 0 | 0 | 1 |
| r11u117repro | 1 | 0 | 0 | 1 |
| r11u13repro | 0 | 1 | 1 | 0 |
| r11u1repro | 0 | 1 | 1 | 0 |
| r11u5repro | 0 | 1 | 0 | 1 |
| **total** | 102 | 213 | 197 | 118 |

## Sources, and the cases left, pass by pass

### r10earl_repro

Source: `tools/probe/r10earl_repro/README` (no extension; its sections
"LANDED — PASS n" name each witness file beside its `§` law), checked against
the Earlgrey pass 1-15 commits (daa9eb05, 8cdbe580, 418f7fdd, f5fbd257,
fc32cb1a, 322f5295, 5a3b5ad3, 09c0984d, 2875f825, 54b501ff, e05ba84a,
c1d34b20).

* `a`: pass 1 LAW 1, "the adjustSize exemption for BASED literals in a package
  unpacked-array pattern". The `elemSz9` re-stamp site in ParamEmit names it
  `§ adjustSize`. Law: `adjustSize`.
* `b` `c` `r`: `pkgStringDecompileQuoted` (pass 1 row `b.sv/c.sv`, pass 2 row
  `r.sv`).
* `f` `g` `l`: the `crossPkgRangeBoundFold` row. The row also says "f.sv, g.sv
  and l.sv ... are BYTE-IDENTICAL after this plus the next law", which is
  `unsizedBasedTypedParamElab` (each case has typed `'h0` defaults). Both laws
  are listed.
* `i`: `crossPkgRangeBoundFold` (the row's "i.sv row 18" distinguisher).
* `h` `o` `p`: `unsizedBasedTypedParamElab`.
* `e`: the README lists it as the witness of the wildcard-import family (ranked
  residue: "work@padring — WILDCARD-IMPORT MATERIALIZATION (e.sv)"). Its
  `padr` module is the padring shape that the `§ pkgBoundFoldBareImport` source
  comment cites (TypeEmit `crossPkgFoldBoundLeaves9`). Its `sram2` module is
  the qualified `crossPkgRangeBoundFold` shape. Both laws are listed.
* `dd`: the flat `.name` shorthand alone. This is `bb.sv`'s row B, "the same
  instance OUTSIDE a gen block, as the control" of `genRefModuleImplicitPort`,
  just as `ee` is row A alone. Law: `genRefModuleImplicitPort`.
* `s`: `uninstDefPortedAdmit`. `t` (the "NEGATIVE witness for the law above,
  kept deliberately") and `u`: `pkgFuncFillSizedInElab`. `x`:
  `syntaxMultiConcat`. `y`: `syntaxUnsizedBasedSize`.
* `ii`: the pass-5 control that "proves the fixed-dim shape was never the
  problem and sent the decode to the symbolic-dim rule". Its
  `assign r = ip::RSP_DEFAULT` is the scoped-reference trigger. Law:
  `symDimScopedRefFlat`.
* `ll`: `impArithFoldSigned`. `nn`: `deferredPortUnpackedArrayTs`. `qq`:
  `genConnOperatorActual`. `ss`: `modParamCastBindScope`.
* `ta`: `genSyntaxSizeDim`. `tc`: `enumSubstDecBare`. `td`:
  `genConnOperatorActualFirst` and `genConnIdxOpTree`. `tj`:
  `hpMidGenvarSelect` and `genConnDotSelInterior`.
* `ua`: `sysCallArgOperatorTree`. `uf`: `shadowedImportBoundFold`,
  `genForInitPkgParamFold` and `defDimPkgParamFold` (three rows name it).
  `ve`: `castSizeParamRefBindFinal`.
* `vf`: `modDefImportPatSel` (pass 11) and `structParamBareImportRef` (pass 12,
  "vf.sv is now cmp-EQUAL").
* `vj` `vk`: "the negative controls that got the decode there" of
  `defOnlyNoArgTs`.
* `vo`: `hierSelPkgParamFold`, `hierSelWidthOvParamNoFold` and
  `caPartSelBoundFoldTs` (two pass-12 rows).

Left without a LAW file (7). Each is a witness the README records as not
exercising any law:

* `cc`: "cc.sv (flat only)" is the control of a pass-4 RESIDUE (the DEF-view
  lowConn with gen and flat mixed). No law landed for it.
* `rr`: "NEGATIVE WITNESS ... it does NOT reproduce".
* `tl`: "NEGATIVE WITNESS ... it does NOT reproduce".
* `wf`: "a MEASURED NEGATIVE". It did not reproduce.
* `py20`: a pass-20 NEGATIVE.
* `qd25`: FULLY CMP-EQUAL. It refutes a hypothesis.
* `qa28`: "a REFUTATION witness", untouched by both pass-28 laws.

### r11u15repro

Source: README §4. The LAW B axes table lists the `a*` cases and the LAW A axes
table lists the `b*` cases. Commit 76c8a58b and the source comments name LAW A
`§ genCaDrivenOpenerIsGenLocalOnly` (ModuleEmit) and LAW B
`§ wholeWriteIsNotTheDiscriminatorForANET` (StmtEmit).

* `grid/a*` (21): `wholeWriteIsNotTheDiscriminatorForANET`.
* `grid/b*` (19): `genCaDrivenOpenerIsGenLocalOnly`.

Left: none.

### r11vu15repro

Source: this pass verifies r11u15 (see its title). The README has two tables,
"LAW B (part-select owns the name)" and "LAW A (a generate scope's cont-assign
reads the module symbolically)".

* `v01`-`v09`, `v20`-`v23`, `v30`, `v31`:
  `wholeWriteIsNotTheDiscriminatorForANET`.
* `v11`, `v14`, `v15`, `v17`, `v18`, `v19`, `v26`:
  `genCaDrivenOpenerIsGenLocalOnly`.

Left: none.

### r11u108repro

Source: README Q2 and Q3, and `evidence/GRIDS.txt`. `grid/pk/k05_param_a` is
named in the FACE 2 section (`§ defPkgMemberTdOfNamedShares108`) as that face's
residue: "Golden's DEF listing omits typedefs of this kind from `vpiTypedef`
(k05, k12)". It gets that law.

Left without a LAW file (38): `grid/f4/*` (12) and `grid/pk/*` other than k05
(26). FACES 1, 3 and 4 are "STOPPED AT THE DECODE (site fenced)" and the README
gives them no law name. Every one of these cases is `SAME` law-vs-pristine in
`GRIDS.txt`. FACE 4 landed later as r11u112's `modFnLocalTdCastClone112` and
`modFnLocalTdRetClone112`, which are not laws of this pass.

### r10rgg3repro

Source: README "The law" and `GRID.txt`. The measured table marks cells
p1/p2/p4/p5 as "clause (3)". The `§ ifaceArrayElemViewFoldsDefault` source
comment (ModuleEmit) cites "r10rgg3repro/GRID.txt cells p1/p2/p4/p5". The
`§ portViewRangeRecvParams` comment carries the a/b/c/d/n rows.

* `p2_multiparam_arr_norecvp`: `ifaceArrayElemViewFoldsDefault`.
* `p1`, `p4`, `p5` (receiving AW=5, so the substitution also applies): both
  `ifaceArrayElemViewFoldsDefault` and `portViewRangeRecvParams`.
* Every other cell, including the module contrasts `i1` and `n7` ("Modules are
  unaffected") and the home-like controls `a1`/`a2`/`e*`/`g2`/`l1`:
  `portViewRangeRecvParams`.

Left: none.

### r10vrgg3repro

Source: this pass verifies r10rgg3 (see its title). The README series table and
`GRID.txt` §3 were used.

* `z5`, `z6`, `z9`: "THE BYPASS BOUNDARY — the four exceptions
  `arrElemPortView9` newly overrides". Law: `ifaceArrayElemViewFoldsDefault`.
* `v5_iface_gen_depends_on_aw`: a generate-bearing interface (the `ifaceHasGen9`
  exception) with an array element view and a receiving AW. Both laws are
  listed.
* Every other `v*` `x*` `y*` cell, including the preserved control
  `xb_module_array_contrast` and the home-like control `z1_single_genfor_named`:
  `portViewRangeRecvParams`.

The pass's own crash guard, `defPortsNullDefInstGuard`, has no gate case. Its
shapes are in `crashclass.sh`.

Left: none.

### r10sd10repro

Source: README §4.2. Left without a LAW file (27): the `g*`, `grid7_*`, `q*` and
`v1`-`v3` cells. They are the sd4-sd9 kits, "RE-RUN as 4.2's boundary checks"
and byte-identical between the two binaries. Their headers name the earlier
passes' import-copy and queue-local faces, not
`classTdLocalVarKindFollowsCompileOrder10`. Their laws belong to those earlier
passes.

### r11u88repro

Source: README §3d, "THE PASS-82/83/85-FAMILY CONTROLS". Left without a LAW
file (13): `a1` `a5` `a6` `c2` `i1` `i4` `i5` `i6` `vf` `x6` `y1` `y2` `y6`.
They are byte-identical between the two binaries and `NONE = 0` in the §5
switch ledger. They are carried controls of earlier passes' laws, not of this
pass's three laws.

### r10rggen7repro

Source: the plain `README` ("file -> law it pins").

* `t1`, `t2`, `t3`: `defGenCallNoBind` (t1 is its control: "the control that
  showed the law is real").
* `t4`: `ifaceArrayPassThruActual`.
* `t5`: `genRegionCondNoEnumBind`.
* `t6`: `enumConstOvEnc`.
* `t7`: `genCaUnbasedSizing`.
* `t8`, `t9`: `genProcParamFold`.

Left: none.

### r11u112repro

Source: README §2 and R1b. Left without a LAW file (9): `grid/f/r01`-`r09`.
This is the R1b face, "the typed package parameter's range bound is sized by
its type ... FENCED", and the face stops at the decode. `GRID112.txt` reads the
same for pristine and law. It landed later as r11u113's
`typedPkgBoundElabSize113`, which is not a law of this pass.

### r10imex_repro

Source: the plain `README`, and the ModuleEmit comments that cite
`r10imex_repro/t*`.

* `t1`, `t6`: `modportExprPort`. The source comment reads "Three measured forms
  (r10imex_repro/t1, t6 ...)".
* `t2`, `t4`, `t5`: `genericIfacePortNameMatch`.
* `t7`: `genericIfacePortPositionalNoView`.

Left without a LAW file (1): `t3`, the `const` interface members. The README
describes this rule but gives it no `§` name, and no source comment names it.

### r11u14repro

Source: README title `§ modEvalFuncLeftoverEnc` (the pass's single law) and its
grid table. `c3`-`c6` convert. `c8` and `c10` are the package-twin and view
controls of the same grid. All six get `modEvalFuncLeftoverEnc`.

Left: none.

### r10uvm49repro

Left without a LAW file (5): `a2`-`a6`. Its README title says this is "a
MEASUREMENT-ONLY pass. NO production code". No law landed.

### r11u17repro

Source: README §3. Left without a LAW file (4): `e01`, `e03`, `e04`, `e05`. They
measure "the neighbouring fold ENCODING face", which is residue R1 and
byte-unchanged by this pass. They exercise neither of the pass's two laws.

### r11u51repro

Left without a LAW file (4): `b3_leafsubst_ca`, `e1_ca_rhskind`,
`va1_bits_signal`, `vb2_concat_bound`. The README title says "MEASUREMENT
ONLY": this is a census, and no law landed.

### r10fiot_repro

Source: README table (a5 "how far the evaluator's descent travels", a6 "where
the descent ABORTS", a7 "loops"). The `§ evalReachedCallees` source comment
(TaskFuncEmit) reads "Purpose-built goldens (cases a5/a6/a7 ...)". `a5`, `a6`
and `a7` get `evalReachedCallees`.

Left: none.

### r10itype_repro

Source: the plain `README`.

* `t2`: it "Pins § ifaceIfaceTypedPortOrder".
* `t5`, `t6`: "Together they show the order rule does NOT apply to modules".
  They are that law's module controls.

All three get `ifaceIfaceTypedPortOrder`. Left: none.

### r10rggen6repro

Source: the plain `README`, and commit 6309c86c.

* `t4`: `genLpTsFoldBounds`.
* `t5`: its row names `§ cast-seal` (a law with no name in the index grammar)
  "+ § genLpCaSharedBareTs first sighting (J)". It gets the named law,
  `genLpCaSharedBareTs`.
* `t7`: `genLpCaSharedBareTs`.

Left: none.

### r11u107repro

Left without a LAW file (3): `grid/u01`, `u02`, `u05`. The README says "Face 2
is FENCED". The probe that would verify it was never shipped, so no law of this
pass exercises these cases.

### r11u11repro

Source: README title `§ memSelAsmBaseOv` (the single law) and its grid table.
`a5` and `a8` convert, and `a3` is the byte-identical control. All three get
`memSelAsmBaseOv`. Left: none.

### r10uvm8repro

Left without a LAW file (2): `q1`, `q3`. There is no README. Commit 64f49223
lands LAW Q, LAW E and LAW LV without names, and no source comment names them.

### r11u10repro

Source: README §3. `h9_1e1m_port` and `hD_1e1mvec` are one-element cases, the
controls that "must stay folded", and "the element count is the whole
distinguisher". Both get `unpackedStructArrPatOneElemFold`. Left: none.

### r11u3repro

Source: README title `§ structParamMemberOvBinary` (the single law). g1 "is that
shape and converts", and g2 is the member-kind grid. Both get
`structParamMemberOvBinary`. Left: none.

### r11u99repro

Left without a LAW file (2): `w23_modinnerport`, `w24_modinnerparam`. These
are residues that no law of this pass reaches. They landed later as
`caNestedModPortedDefShell101`.

### r10rggen8repro / r10rggen9repro

Source: the plain `README`s. `r10rggen8repro/t1` gets `elabInstCallDefSub`.
`r10rggen9repro/t8` gets `ifacePortVarHighConn`. Left: none.

### r11u111repro

Left without a LAW file (1): `grid/f4/d02_plain_pos_dep`. The README says
"FACE 4 — STOPPED AT THE DECODE (site fenced)", with no law.

### r11u117repro

Left without a LAW file (1): `grid/g3/r04`. This is "face-3 R5", which was not
landed.

### r11u13repro

Source: README title `§ asmEncFollowsRef` (the single law) and its grid table.
`b6` ("TO-GOLDEN") gets `asmEncFollowsRef`. Left: none.

### r11u1repro

Source: README title `§ ifacePortViewParamAssignsOnly`. `grid2` is the positive
control that "reproduces GOLDEN EXACTLY after the patch", and it gets that law.
Left: none.

### r11u5repro

Left without a LAW file (1): `g2`. The README title says "NO LAW LANDED".
