# r11v158 — adversarial verification of r11u158 (the expression/parameter ground): ACCEPT-WITH-FIX

Base `75226e07` (branch matrix-1.87). The implementer's patch applies clean. Its headline numbers were reproduced
bit for bit with binaries built here. The laws were then broken on fresh cases: two of them move pristine-right
output away from golden on legal SV. Both are fixed here behind their own switches (four refinements, sites in
`src/ExprEmit.cpp` and `src/ParamEmit.cpp`, switch helper in `src/EmitHelpers.h`), and every gate was re-run on
the fixed binary. The verified patch is this directory plus the refinements, on top of the r11u158 patch.

| binary | md5 |
|---|---|
| pristine (built in a fresh worktree of the base; = the main tree's `build/slang-uhdm`) | `2aa918616ddb54c5502f85f387b3e4f7` |
| r11u158 law (built here from the implementer's patch; = the implementer's `law6`) | `9bcd87116e9ecb02cde0473c81e451ca` |
| r11v158 fix (the verified patch) | `e509e01e705f0f7f96a6cf7e2a9814ce` |
| `uhdm-strictcmp` (both worktrees, = the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |

Every binary was frozen (`chmod 555` copy) before it was measured. Sweeps: `/tmp/v11u158_swP` (pristine),
`/tmp/v11u158_swL` (r11u158), `/tmp/v11u158_swF` (fix); workdir names have the same length. The `cmds.txt` audit
reads, per sweep, 3323 files and 3273 slang lines, all naming that sweep's frozen binary
(`pris.bin` / `law.bin` / `fix2.bin`). The only red line in every sweep (pristine included) is `law index STALE`,
which comes from the worktree's abbreviated commit hashes (git's `%h` is longer now); `tests/LAWS.md` is regenerated
in the verified patch.

**The fence.** No binary, script or reader touched a slang-fenced test's source or database outside the gate
sweeps. The firing census (`drivers/census.sh`) refuses to run without `$FENCED` and dispatches the corpora with
`--filter '^(?!(<the four>)$)'` ("fenced mentions: 0"). `drivers/rowrec.sh` (record attribution of a sweep row)
refuses a fenced name. A grep of this directory for the four names reads 0.

## 1. Reproduction of the implementer's numbers (bit for bit)

| axis | pristine sweep | r11u158 sweep | implementer |
|---|---|---|---|
| probe | EQUAL 2514 / STRICT_NOTEQUAL 1573; regressions=0 conversions=0 changes=0; `probe.csv` byte-identical to `results/golden_probe.csv` | EQUAL 2528 / 1559; regressions=0 conversions=14 changes=44 | same (`probe.csv` byte-identical to the implementer's) |
| surelog | 425 + 423 = 848 CMP_EQUAL; regressions=0 conversions=0 changes=0 | 429 + 426 = 855; regressions=0 conversions=7 changes=15 | same (csv identical but for the LowMem SURELOG_FAIL detail path) |
| uhdm2rtlil | 751 + 751 = 1502 | 754 + 754 = 1508; regressions=0 conversions=6 changes=0 | same (csv byte-identical) |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2; not identical and not excused=0 | same; 0 of 871 verdicts move | same (csv byte-identical) |
| byteverify (SELFCHECK=1) | — | surelog 35/960 movers (selfcheck 959/960), uhdm2rtlil 10/1608 (1607/1608), probe 62/4087 | the implementer's evidence files list the same 35 + 10 sets; its README table says 36 and 11 (a count slip, the sets are equal) |
| canaries | surelog ok=52 changed=0, u2r ok=16 changed=0; ctcan2 PASS, PASS | surelog ok=48 changed=4 (SVSwitch d/t, SimpleConstraint d/t), u2r ok=14 changed=2 (MultirangesStartNotFromZero d/t); ctcan2 PASS, PASS | same |

The fresh conversion rows (all from the r11u158 sweep, identical in the fix sweep):

    surelog:     EnumVar,default|testflags,CMP_EQUAL,,,equal
                 HierPathStructTypespec,default|testflags,CMP_EQUAL,,,equal
                 LocalScopeHierPath,default,CMP_EQUAL,,,equal
                 SimpleConstraint,default|testflags,CMP_EQUAL,,,equal
    uhdm2rtlil:  MultirangesStartNotFromZero,default|testflags,CMP_EQUAL,,,equal
                 expr_width_cast,default|testflags,CMP_EQUAL,,,equal
                 portsel_struct_param,default|testflags,CMP_EQUAL,,,equal
    downstream:  expr_width_cast,IDENTICAL,NO_GATES,NO_GATES,0,0,,
                 MultirangesStartNotFromZero,IDENTICAL,NO_GATES,NO_GATES,0,0,,
                 portsel_struct_param,IDENTICAL,OK,OK,1,1,,

The prediction: every byte mover of the r11u158 sweep is in the implementer's `predicted_movers.tsv` except
EnumVar d/t, which the implementer disclosed (the § enumAliasEndAtDimOrInitDecl158 trace sits on the other
branch). Record attribution re-measured here with `drivers/rowrec.sh` (walk-aligned strict records vs the row's
golden): EnumVar d 3 records leave, 0 enter; LocalScopeHierPath d 3 leave; HighLow d 4 leave (value(1) stays);
StructUnsizedVal d 1 leaves; SVSwitch d 16 leave, 0 enter (2490 -> 2474, walk diverged on both); CovMacro d 0 leave,
0 enter, 16 of the 118 records change text (fullname 16 -> 8; R7, the macro-body coordinates).

The implementer's grids (`r11u158repro/cases`, 74 cases): 36 go to strict-equal (10 of them from NOT_EQUAL), 18 are
equal on both, 20 stay, none worsens. Its per-law switches each move only their own cases
(`evidence/switches_r11u158_laws.txt`). `R11U157_OFF=1 R11U158_OFF=1` on the fix binary gives pristine bytes on all
232 cases of the three grids (r11u158repro 74, r11u157hp 57, this directory's 101); `R11V158_OFF=1` gives the
r11u158 bytes on all 232 (`evidence/offbytes.txt`).

## 2. The breaks (fresh cases, judged against the pinned Surelog)

Grid runner: `drivers/grid.sh` / `drivers/run3.sh` (golden with check_probe's arguments, uhdm-cmp, uhdm-strictcmp,
output md5), downstream through the harness machinery (`drivers/ds.py`, `ds.one`, fresh `GOLDEN_CACHE`). Full
table: `evidence/grids_pristine_law_fix.txt`, `evidence/downstream_sc_grid.txt`.

**B1 — § sizeCastCaLitMask158, an assignment NARROWER than the cast (uhdm-cmp regression).** The law masks to the
cast width but writes the assignment's width. Golden truncates to the assignment: `logic [1:0] p; assign p =
4'(13)` is UINT:1 size 2. The law wrote UINT:13 size 2. Pristine is STRICT_EQUAL, the law is NOT_EQUAL at stage 1:
`sc/b01` (`4'(13)` into 2 bits), `b02` (`40'(300)` into 8), `b13` (`4'(-1)`, `8'(-3)`), `b14` (`4'(V + 6)`,
`6'(-V)`), `b15` (`2'(3)` into 1 bit, `5'(31)` into 4), `n2` (`W'(13)`, W = 4, into 2 bits). Downstream reads
IDENTICAL on all three binaries (the plugin truncates), so only the judge sees it.

**B2 — § sizeCastCaLitMask158, a bare SIGNED sized literal (downstream regression).** Golden treats `3'sd7` like a
signed name: `2'(3'sd7)` into logic [3:0] is INT:-1 size 4, `2'(3'sd5)` INT:1, `3'(4'sd7)` into 8 bits INT:-1 size
8. Pristine wrote UINT:15 (the same bits); the law wrote UINT:3. `sc/b03` goes downstream IDENTICAL -> DIVERGENT
(nohier, il, synth), `sc/w6` EQUIVALENT -> DIVERGENT. (`2'(-3'sd1)`, an operator tree, is UINT:3 in golden: the
law is right there.)

**B3 — § arrQueryFoldAtBound158, a variable, net or port argument (a strict cell moving away from golden).** For a
parameter argument golden folds `$high(a)` at the range bound (the law's cases). For any other argument golden keeps
the CALL's span: `logic [5:2] v; parameter high = $high(v)` folds at 4:20-28 in golden and pristine, the law
moves it to 3:10-11. The same holds for a net (`hl/x3`, `y2`), a port (`x8`, `y1`, `y4`, `h03`), an unpacked
variable (`h01`) and a variable with an `int` localparam (`h08`, `y3`). Every one of these cases is NOT_EQUAL at
stage 1 on all binaries (the elaborated net binding in `$high(v)`), so no gate sees it, but the field itself
leaves golden. An UNPACKED parameter (`parameter [7:0] m [0:3]`, `x1`) is not folded by golden at all (the
`sys_func_call` stays); the law moved our fold to the packed bound.

No break found for the other laws: § enumAliasEndAtDimOrInitDecl158 (12 cases: two top modules in either order, a
packed dimension on the type, `var`, a procedural or continuous writer, a declaration in a generate block or a
child; wins v05, v08, v12, v14 fullname-only), § genCaLhsEnumConstClone158 (8: concatenation target, struct member
target, two instances with different generate counts, a generate-case block, a net declared in the generate scope,
an interface generate scope, package-qualified constants; g04, g05 convert, g07 law = golden on the object), §
pkgFoldLeftParenSpan158 (4: `(A) + B`, `($clog2(A)) * 2`, `(A - 1) - (A - 2)`, `(A + 1) % 3` in a localparam; col
records leave), § aggParamFoldUnqualWholeSpan158 (8: explicit import, a package-local default, a module-body
import, a header item import, an instance override; the endcol record leaves in a05-a08), §
methodRandomizeCallSpan158 (6: assert/if/void', `this.i.randomize()`, `with`, `randomize( )`, `randomize (null)`,
an element receiver; z01, z03 convert), § sizeCastCaSignedSize158 (b08 q = golden INT:-1 size 8, b16), and the
r11u157 laws (9 module and class cases: ternary branches, replication count, select index, loop bound, case item,
`$display` argument, indexed part-select base and width, `this.` inc/dec forms, foreach over a member, `$root`
paths, generate-block targets; r07 9 -> 1 differing records, r10 converts, r05 Cfg.D elements = golden).

Also found (pristine and law both wrong, recorded, not a break): a WIDTH WRITTEN AS A NAME is not applied by golden
(`W'(-1)` W=3 into 8 bits -> UINT:255; `W'(7)` W=2 -> UINT:7; `pk::W'(7)` -> 7; `W'(V)` -> 7; into 4 bits
`W'(-1)` -> 15), while a width expression masks (`(W+1)'(15)` -> 7, `(2)'(15)` -> 3). The implementer's `SEL_W'(3)`
cases (c1, c2) agree with golden only because 3 fits in 2 bits. Pristine and the law are DIVERGENT downstream on all
of them. Refined below (R3), since the brief's item (3) is exactly this shape.

## 3. The refinements (r11v158; each under its own switch, `R11V158_OFF` drops all four)

| law | switch | site | rule |
|---|---|---|---|
| § sizeCastNarrowTargetAbstain158v | `R11V158_SCNARROW_OFF` | ExprEmit.cpp tryFoldConst (the § sizeCastCaLitMask158 block) | the law abstains when the assignment is narrower than the cast (the pristine fold, which is golden) |
| § sizeCastSignedLitAbstain158v | `R11V158_SCSLIT_OFF` | same | the law abstains on a bare signed sized/based literal operand (`!isDeclaredUnsized && value signed`) |
| § sizeCastNamedWidthNoCast158v | `R11V158_SCNAMEDW_OFF` | same | a width written as an `IdentifierName` or `ScopedName` (not a typedef: the cast type is not an alias) is not applied: the operand's value (a bare name operand included) at the assignment's width, UINT |
| § arrQueryParamArgOnly158v | `R11V158_AQPARAM_OFF` | ParamEmit.cpp arrQueryBoundLoc158 (§ arrQueryFoldAtBound158) | the bound location applies only to a PARAMETER argument that is not an unpacked array |

`R11U158_TRACE=1` prints `V:SCNARROW`, `V:SCSLIT`, `V:SCNAMEDW`, `V:AQPARAM` when a refinement decides.

Per-switch movers (`evidence/switches_refinements.txt`, bytes vs the fix binary all-on, over the sc and hl
cases of both grids): SCNARROW: b01 b02 b13 b14 b15; SCSLIT: b03 w6; SCNAMEDW: r11u158repro sc/c12, b10 n1 n3 n6 n8
n9 w1 w3 w4 w7; AQPARAM: r11u158repro hl/h4, h01 h03 h08 x1 x2 x3 x8 y1 y2 y3 y4.

Case results (pristine | r11u158 | fix, `evidence/grids_pristine_law_fix.txt`):
* B1 cases b01 b02 b13 b14 b15 n2: STRICT_EQUAL | NOT_EQUAL | STRICT_EQUAL, fix bytes = pristine bytes.
* B2 cases b03, w6: downstream IDENTICAL | DIVERGENT | IDENTICAL and EQUIVALENT | DIVERGENT | IDENTICAL (b03 fix
  bytes = pristine; w6's `2'(-3'sd1)` keeps the law's golden UINT:3). n7, w5 (`2'(3'sd5)`) are pristine bytes.
* B3 cases h01 h03 h08 x1 x2 x3 x8 y1-y4 and r11u158repro hl/h4: fix bytes = pristine bytes (the call span).
  The law's own cases (h1 h2 h7, and x4 x5 x7 here) keep the law's bytes.
* Named width: b10 n1 n3 n6 n8 n9 w1 w3 w4 w7 go NOT_EQUAL -> STRICT_EQUAL and downstream DIVERGENT -> IDENTICAL.
  r11u158repro sc/c12 (the implementer's sister residue S3, `W'(7)` in a child whose W an instance overrides) goes
  NOT_EQUAL -> STRICT_EQUAL and downstream DIVERGENT -> EQUIVALENT. Typedef casts t1 t2 keep pristine bytes.

## 4. Gates on the fix binary (`e509e01e…`)

| gate | result |
|---|---|
| (1) build | the fix worktree builds; pristine md5 = main tree |
| (2) probe | EQUAL 2528 / STRICT_NOTEQUAL 1559; regressions=0 conversions=14 changes=44; `probe.csv` identical to the r11u158 sweep's |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 7 + 6; changes 15 + 0; both csvs identical to the r11u158 sweep's (paths normalised) |
| (4) downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2; not identical and not excused=0; csv identical to the r11u158 sweep's and to the pristine sweep's verdicts |
| (5) uhdm-cmp | every mover keeps its judge-equal status (0 regressions in all three stages) |
| (6) byteverify fix vs r11u158 | surelog 6/960 (selfcheck 959/960), uhdm2rtlil 0/1608 (1607/1608), probe 0/4087 (the probe stage re-run from the pristine worktree root so the databases' paths match) |
| byteverify fix vs pristine | surelog 35/960, uhdm2rtlil 10/1608, probe 62/4087 (the same sets as r11u158) |
| canaries | identical csvs to the r11u158 sweep: surelog ok=48 changed=4, u2r ok=14 changed=2 (attributed in section 1); ctcan2 PASS, PASS |

**Prediction before the fix sweep** (`evidence/predicted_movers_fix_vs_law.txt`, fence-filtered census of the fix
binary, `evidence/census_*.log`): the refinements fire only as `V:SCNAMEDW` on StreamOperatorBitReverseFunction d/t
(`XLEN'('h89abcdef)` into 32 bits), Scr1SvTests d/t and 5 probe cases (r10earl106repro g1_home106, h1_head106,
r10earl50repro h6_earl50, r10earl51repro i1_earl51, r10vearl106repro va5_scope106). None of them moved: each value
fits its width, so masking and not casting write the same constant. **The 6 surelog movers of the fix sweep were
not predicted: MiniAmiq d/t, SeqDriver d/t, SimpleUVM t, Scoreboard d.** They are the known UVM coin
(`evidence/uvm_coin_fix_vs_law.txt`): Scoreboard d differs by 92 ordered lines and 0 order-blind lines (the svunit
order coin), and the other five by exactly 4 lines, a `UINT:`/`vpiDecompile:` pair swapping values (1144/745,
0/1454). No refinement fires on those rows, and their csv rows are identical.

## 5. Residues (ranked, with the ground)

1. The implementer's list stands (r11u157 R2/R3; R-SP makeParamTs member names; ParamNoImport; N0472; `gl/l4`;
   LocalScopeHierPath t; `ev/e16`; `hl/h3`; FuncIoTypespec; R6-R9) and its sister-ground faces S1, S2, S4-S8. S3
   (`sc/c12`) is now strict-equal; its downstream reads EQUIVALENT (was DIVERGENT).
2. A size cast inside a larger continuous-assign value (`assign p = 2'(3) + 1`, `~2'(1)`, `sc/b09`): DIVERGENT
   downstream on every binary. tryFoldConst folds the whole operation; the cast's own reduction would have to
   follow the same unsigned-mask rule inside the tree (ExprEmit tryFoldConst).
3. A bare signed literal operand (`2'(3'sd7)`): golden is the signed branch (INT at the assignment width), ours UINT
   of the same bits (downstream IDENTICAL). The signed branch excludes literals (`signedSizeCast`); a signed-literal
   entry at the assignment's width would convert `sc/b03`, `n7`, `w5`.
4. `3'(V)` into a 2-bit target (`sc/b08` p): golden INT:-1 size 2, ours UINT:3 (pre-existing, both binaries).
5. A parenthesised `randomize()` (`ok = (p.randomize());`, `rz/z06`): the path still ends at the name (one endcol
   record on all binaries), § methodRandomizeCallSpan158 does not reach it.
6. `$high` of a variable/net/port argument: stage-1 NOT_EQUAL on all binaries (the elaborated reference), so its
   now-correct span is not yet gate-visible.

## 6. Files

* `cases/` (101 cases; the first line of each names its law): `sc` (35), `hl` (19), `ev` (12), `gl` (8), `hp` (9),
  `rz` (6), `uq` (8), `pp` (4). The refinement cases name the refinement: § sizeCastNarrowTargetAbstain158v (b01
  b02 b13 b14 b15 n2), § sizeCastSignedLitAbstain158v (b03 w5 w6 n7), § sizeCastNamedWidthNoCast158v (b10 n1 n3 n6
  n8 n9 w1 w3 w4 w7 t1 t2), § arrQueryParamArgOnly158v (h01 h03 h08 x1 x2 x3 x8 y1 y2 y3 y4); the others name the
  r11u158 / r11u157 law they attack.
* `drivers/`: grid.sh, run3.sh, ds.py, recdiff.py, paramassign.py, rowrec.sh, census.sh + tracewrap.sh.
* `evidence/`: the files named above.
