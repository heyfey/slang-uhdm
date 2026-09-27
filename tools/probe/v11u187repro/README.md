# v11u187 — adversarial verification of r11u187 (the expression/parameter ground: seven r11u183 ground-A laws and § trailIdxCallArgNamesByPath187 / § trailIdxSelNamesByPath187): ACCEPT, one law-index attribution fixed, composition with pass 186 measured

Verifier of `tools/probe/r11u187repro` (implementer patch `r11u187.patch`, base `44393367`). Fresh worktrees at
`44393367` (pristine and patched), both binaries built here with `-j 1` (system deps) and frozen before any
measurement. Pass 186 (the sister, module/type ground) landed as `c168c2095` during this verification, so the patch
was also applied 3-way to `c168c2095`, built, and gated there (section 4).

## Verdict

ACCEPT. Every headline number of the implementer reproduces bit for bit; no fresh case moves away from golden; each
law is droppable alone; `R11U187_OFF=1` writes the pristine bytes on every probe case at both bases. One defect fixed
in `r11u187.verified.patch`: the implementer's cases `T/t05` and `T/t06` named a law that does not exist
(`trailIdxPartSelNamesByPath187`), so `tests/CASES.csv` attributed them to nothing; their first line now names
§ trailIdxSelNamesByPath187 and `tests/LAWS.md` is regenerated. The sources are byte-identical to `r11u187.patch`.

## Binaries (`chmod 555`)

| binary | md5 | what |
|---|---|---|
| pris.bin | `948f24885e7b03e37e1451b8c8152303` | worktree build of `44393367` (= the main tree's build at that base) |
| law.bin | `515bf9a120cb976747a20f88cde3d662` | `44393367` + `r11u187.patch` (= the implementer's law4.bin) |
| pris186.bin | `31cca146e477f929354b62ba79ce40b6` | worktree build of `c168c2095` (= the main tree's build at that commit) |
| comp.bin | `f3d278ab9facf11047ced4937ea134cd` | `c168c2095` + `r11u187.patch` (3-way; only `tests/LAWS.md` conflicts; regenerated) |
| uhdm-strictcmp | `5d4617d0458f34aa79e0b91009d5d1fc` | the main tree's |

Every `cmds.txt` of every sweep names its own frozen binary on all 3273 `slang:` lines (0 other).

## 1. Reproduction at 44393367 (sweeps swP = pris.bin, swL = law.bin; `evidence/sweeps/`)

| stage | swP vs committed | swL vs committed |
|---|---|---|
| probe | reg 0 conv 0 chg 0 (EQUAL 2898) | **reg 0 conv 10 chg 19 (EQUAL 2908)** |
| surelog | reg 0 conv 0 chg 0 | **reg 0 conv 2 chg 9** (ArrayMethodIterator d/t convert) |
| uhdm2rtlil | reg 0 conv 0 chg 0 | reg 0 conv 0 chg 2 (jeras_union d/t fullname(75) -> fullname(15)) |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0; the two csvs byte-identical |

swL `SWEEPRC=0` (law index current). swP exits 1 only for `law index STALE`, which every worktree at a landing commit
reads (the committed index cannot hold its own commit: the same at `c168c2095`).

Fresh conversion rows (results/ untouched):

    ArrayMethodIterator,default,CMP_EQUAL,,,equal
    ArrayMethodIterator,testflags,CMP_EQUAL,,,equal

The ten probe conversions and nineteen changes are exactly the implementer's list (`sweeps/sweep_swL.log`,
`sweeps/csv_rowdiff_base.txt`).

**Byte movers.** Corpus (fence-free mirrors, 2560 databases, 8 fenced skipped, SELFCHECK 2559/2560): 17 movers,
the implementer's 17 exactly (`sweeps/byteverify_corpus_base.txt`). Earlgrey_0_1 testflags (no law fires on it: the
trace directory stays empty) is the known Earlgrey draw: run five times in a row from its own directory, law.bin wrote
`99fc8d82ca9b` (the pristine hash), law.bin with `R11U187_OFF=1` `99fc8d82ca9b`, with `R11U187_TRAILCALL_OFF=1`
`76f319c5d8a6`, with `R11U187_TRAILSEL_OFF=1` `76f319c5d8a6`, pris.bin `99fc8d82ca9b`: the same binary draws both
hashes (pass 186's § lawSCopyIdOrder186 closes the coin; at `c168c2095` it is not a mover, section 4). Probe: 32
movers, the implementer's 32 exactly (`sweeps/probe_movers_base.txt`). Downstream lane: 1 mover, jeras_union, its
`_nohier.il` byte-identical between the lanes' runs, verdict IDENTICAL.

**Every change judged** (`row_judge_movers.txt`: first strict record and order-blind record distance to golden).
The UVM rows whose count grows keep the same first record and fall in distance: MiniAmiq d 28913 -> 23588, SeqDriver
d 21287 -> 17680, SimpleUVM d 7000 -> 6969, Scoreboard d 5652 -> 5619; status-silent movers: Rggen d 17193 -> 12313,
BuildUVMPkg d/t 3275 -> 3250. The probe changes that grow or switch field (grid `drivers/grid.sh`, order-blind):
g193_c_argface 264 -> 235, t32d_t 66 -> 26 (the new `type` head is the class-property loop variable golden types
with the property's array_typespec, a face § cloneLoopVarHomeObject183 does not claim), v181_h_nofe 43 -> 40,
v208_f_io 156 -> 48.

**Switches** (`switch_matrix_probe_movers.txt`, `drivers/swmat.sh`): on each of the 32 probe movers, the switch of
the law that fired alone writes the pristine bytes, every other switch the law bytes, and `R11U187_OFF` the pristine
bytes; the two-law cases (a1_hp2, a2_hp1, b3_edges: both 187 laws; g193_c_argface: two r11u183 laws) read an
intermediate database under one switch. `R11U187_OFF=1` on law.bin over all 4087 tests/probe cases: 4087 pristine
databases (`drivers/probe_run.sh`).

**Canaries.** `canaries.sh` surelog ok=45 changed=7 (ApbSlave d/t, SimpleUVM d/t, SeqDriver d/t, Scoreboard d, as
claimed), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh`
uhdm2rtlil PASS.

## 2. Breaking the laws: 64 fresh cases x both views (`cases/`, `grid_fresh_base*.txt`)

Every case names its law on its first line. Judged by uhdm-cmp and uhdm-strictcmp against the v1.87 golden of the
same view, pristine vs law, with the order-blind record distance; judge-unequal pairs by the order-blind uhdm-dump line
distance (`drivers/dumpdist.sh`). Result over 128 case-modes: 43 unmoved, 54 TOWARD (strict records), 31 judge-unequal
on both binaries and moved, all toward or at equal dump distance, **0 away**.

| law | cases | result |
|---|---|---|
| § aliasFoldBoundFile183 | A/a11 (target typedef in an include inside the package), a12 (alias in an include, W-1 bound), a13 (alias of an alias) | a11 distance 80 -> 0 (def) / 88 -> 0 (elab); a12 126 -> 26; a13 judge-unequal on both: the fold constants gain `dut.sv`, golden's file (read off golden's own record walk) |
| § blockSizeDimEndsAtExpr183 | C/c11 (`[0:1][2]`), c12 (`[2][0:1]`), c13 (packed element, `N*2`), c14 (macro size), c15 (`$bits(byte)`), c16 (initial block), c17 (named block, typedef element), c18 (`pk::N`), c19 (parenthesized, class method) | c11 c16 c19 convert in both views; c12 fires and writes the pristine bytes (the range dimension written last keeps the bracket); c14 def endcol -> type; c13 c15 c17 c18 judge-unequal on both, dump distance falls |
| § macroIfacePathTokSpans183 | P/p11 (index from an argument), p12 (whole path from one argument), p13 (member from an argument), p14 (nested macros), p15 (two dimensions, modport), p16 (spaces around the dot), p17 (part-select and variable-index lvalues), p18 (included macro, generate loop, `i+1`) | p11 p14 p16 convert; p12 p17 p18 fall (8 -> 4, 12 -> 4, 12 -> 4); p13 p15 judge-unequal on both, falling |
| § withClauseCloseParenEnd183 | W/w11 (`find(x) with`), w12 (no parentheses), w13 (whole call in a macro body), w14 (comment before `)`), w15 (class method), w16 (clause from a macro argument), w17 (`min` over a fixed array) | w14 def endline -> type (6 -> 2), elab dump 36 -> 24; w13 w16 decline (the `)` in another buffer); the rest unmoved |
| § cloneLoopVarHomeObject183 | G/g11 (dynamic formal), g12 (packed vector formal), g13 (`foreach (a[i, j])`), g14 (local array), g15 (`[int]`), g16 (`[byte]`: the placeholder kept), g17 (class property), g18 (string queue called from a module), g19 (typedef array), g20 (2-D formal, one variable), g21 (`ref` / `const ref`), g22 (class method, subclassed in another package) | g11 g13 g15 g16 g20 g21 convert; g12 fullname(20) -> endcol(2); g14 g18 g19 judge-unequal on both, falling; g17 g22 unmoved |
| § defCloneRefsBindDefListing183 | H/h11 (write), h12 (two classes, struct member read), h13 (property shadows the variable), h14 (typed class parameter), h15 (package function and method), h16 (extern method called through a module handle), h17 (untyped class parameter) | h16 h17 def `depth -> endcol` (6 -> 2, 10 -> 6); h14 judge-unequal on both (an unrelated `int` class-parameter head), the clone's `base` now binds the definition listing's variable as in h16; h11 h12 h13 h15 fire and write identical bytes |
| § foreachAssocLoopVarIdxTs183 (A half) | F/f11 (subroutine-local `[string]`), f12 (class key), f13 (int-keyed property) | inert at 44393367 on all (no registration); composed at `c168c2095`, section 4 |
| § trailIdxCallArgNamesByPath187 / § trailIdxSelNamesByPath187 | T/t21 (select under a call, call under a select), t22 (if/case conditions, concatenation lvalue), t23 (named argument, two arguments, method call), t24 (array-element base, port connection), t25 (package function body, a formal), t26 (inc/dec and nonblocking two generate levels down), t27 (call in the non-trailing index), t28 (system calls), t29 (genvar and parameter arguments in a generate loop), t30 (ternary, call argument), t31 (indexed part select, nested select, array read in an lvalue), t32 (class property path), t33 (interface-port path), t34 (paths nested under an operation, a call, two levels), t35 (nested paths in continuous assignments and lvalues) | t21 t22 t28 t30 t32 convert; t23 fullname(24) -> file(12); t31 fullname(20) -> col(4); t24 t25 t26 t29 judge-unequal on both, falling (t29 elab moves only objects the walk does not reach); t27 t33 t34 t35 decline (bytes identical: the nested-path decline holds under operations, calls and two levels) |

Downstream (the slang lane's `-DSYNTHESIS` view, `ds.one`): A/a11 a12, C/c11 c16, P/p11 p14 p16 p17 p18, T/t22 t29
t30 t31 t35 IDENTICAL on both binaries; W/w14 EQUIVALENT on both (pre-existing, unchanged).

## 3. Controls

The implementer's 56 cases and the 147 r11u183 cases (both views) are gridded again at `c168c2095` (section 4). No
probe case leaves EQUAL at either base; uhdm-cmp reads 0 lines on every judge-equal mover (the status column).

## 4. Composition with pass 186 at c168c2095 (`evidence/composed/`)

`r11u187.patch` applies to `c168c2095` 3-way: the three sources cleanly, `tests/LAWS.md` in conflict (regenerate
it). Sweeps swQ (pris186.bin) and swC (comp.bin) against the committed baselines of `c168c2095`:

| stage | swQ | swC |
|---|---|---|
| probe | reg 0 conv 0 chg 0 (EQUAL 3026) | **reg 0 conv 13 chg 20 (EQUAL 3039)** |
| surelog | reg 0 conv 0 chg 0 | **reg 0 conv 4 chg 7** (ApbSlave d/t, ArrayMethodIterator d/t convert) |
| uhdm2rtlil | reg 0 conv 0 chg 0 | **reg 0 conv 2 chg 0** (jeras_union d/t convert) |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0; csvs byte-identical; 1 lane mover (jeras_union), IDENTICAL |

Fresh rows of swC (results/ untouched):

    ApbSlave,default,CMP_EQUAL,,,equal
    ApbSlave,testflags,CMP_EQUAL,,,equal
    ArrayMethodIterator,default,CMP_EQUAL,,,equal
    ArrayMethodIterator,testflags,CMP_EQUAL,,,equal
    jeras_union,default,CMP_EQUAL,,,equal
    jeras_union,testflags,CMP_EQUAL,,,equal

Probe conversions beyond the base's ten: r10uvm151repro/g151_a_body (endcol(3)), r10uvm21repro/t (file(2)),
r10uvm21repro/t32b_t (file(6)): g151_a_body is § withClauseCloseParenEnd183 (`R11U183_PATHSPAN_OFF` restores pris186's
bytes), the other two § foreachAssocLoopVarIdxTs183's A half composed with the sister's registration
(`R11U183_FEIDX_OFF` restores pris186's bytes; `composed/switch_matrix_c168.txt`). Corpus byte movers 16 (the base's 17 without Earlgrey: § lawSCopyIdOrder186 closed that coin); UVM
distances fall (MiniAmiq 24998 -> 18655, SeqDriver 19320 -> 14493, SimpleUVM 5927 -> 5794, Scoreboard 4710 -> 4609,
Rggen 16207 -> 11327, BuildUVMPkg 3064 -> 2799). `R11U187_OFF=1` on comp.bin writes pris186's bytes on all 4087 probe
cases (the sister's r11u183 laws read `R11U183_OFF`, not `R11U187_OFF`); 36 probe movers composed. Composed grid (the
implementer's cases, the r11u183 cases, these cases; 267 dirs x 2 views): 310 unmoved, 149 TOWARD, 69 judge-unequal
and falling or at equal dump distance, 2 r11u183 d/f11 where the canonical walk reads equal on both and the raw walk
(`--no-canon`) goes from `depth` to STRICT_EQUAL against golden (the loop variable now shares the index typespec
golden shares), 4 slang failures on both binaries (r11u183 a/c10, h/h09); **0 away**. Canaries at `c168c2095`:
surelog ok=45 changed=7 (ApbSlave d/t convert, SimpleUVM d/t, SeqDriver d/t, Scoreboard d), uhdm2rtlil ok=16
changed=0, both ctcan2 PASS.

## 5. Residues (the implementer's ranking stands; composed state)

1. The ParameterFromPkg rows were converted by pass 186 alone; ApbSlave and jeras_union convert only composed, so
   § defCloneRefsBindDefListing183 and § aliasFoldBoundFile183 are now load-bearing for landed rows.
2. const_cast_signext type(1) (ModuleEmit `emitContAssigns`, beside § evalFuncSelectKeepsCall148), arb_idx_cast
   endcol(17) (TypeEmit `emitTypeParamArrayVar`), the nested-path index names (pass 178's h09, ExprEmit
   `trailSelIdxNames133`), FuncStructVal endcol, § cloneLoopVarHomeObject183's part-select separator face, as
   decoded by r11u187.
3. New from this grid: the class-PROPERTY loop variable's typespec (t32d_t's `type(1)`: golden types it with the
   property's array_typespec, ours keeps the unsupported placeholder; StmtEmit `cloneLoopVarShared37` has no
   property entry in `arrayVarArrayTs`); a macro path whose member comes from a macro argument (P/p12, p13: `col`,
   the argument buffer's columns against golden's expanded-line layout, the face pass 186 refined on its own ground
   with § macroPathTokOneBuffer186); the with-clause call written wholly in a macro body (W/w13 `endline`).

## Files

`cases/` (64 dirs, each naming its law on its first line), `drivers/` (`env.sh`: pins and `$FENCED`, fail closed;
`grid.sh`, `dumpdist.sh`, `obdist.py`, `classify.py`, `swmat.sh`, `rowjudge.sh`, `probe_run.sh`), `evidence/`
(`sweeps/`, `composed/`, the grids, the switch matrix, the row judgements). No fenced test is named anywhere here; the
byte comparisons ran on mirrors that leave the fenced databases out.
