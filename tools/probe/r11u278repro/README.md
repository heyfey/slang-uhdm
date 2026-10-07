# r11u278 — pass 278, the expression/parameter ground (ExprEmit, ParamEmit)

Implementer of pass 278 (pair A, refill after pass 276), base b7d287dcf. Four laws, one in `src/ExprEmit.cpp` and
three in `src/ParamEmit.cpp`, behind `src/R278.h` (each `R11U278_<LAW>_OFF`; `R11U278_OFF` drops all four and gives
pristine's bytes on 198 of 198 grid case-views; `R11U278_TRACE=<dir>` logs every firing and abstention, one file per
process, first line `OUT <-o path>`).

**Verdict.** No corpus row converts or moves (byteverify 0 of 2560 corpus databases and 0 of 805 downstream
databases); **ELEVEN PROBE CONVERSIONS** and four probe changes, every one predicted by name by the firing census
frozen before the law sweep; the Surelog corpus stays at zero open rows (every row-mode CMP_EQUAL except the known
failures LogicTypespec d/t and Scr1SvTests d/t), uhdm2rtlil 1606 + 0, downstream 803 / 66 / 2 / 0 with the csv
byte-identical to pristine's and to the baseline.

Fresh csv rows of the conversions (`results/` untouched; the law sweep's `probe.csv`):

    r10earl29repro/a1_hp2,EQUAL,,equal                      (was differ:fullname(2))  § trailIdxVarSelNamesByPath278
    r10earl29repro/a2_hp1,EQUAL,,equal                      (was differ:fullname(2))  § trailIdxVarSelNamesByPath278
    r10earl29repro/b2_kinds,EQUAL,,equal                    (was differ:fullname(2))  § trailIdxVarSelNamesByPath278
    r10v201repro/v201_k_neg,EQUAL,,equal                    (was differ:line(1))      § elabPkgQualRefRhsPkgTs278
    r11u45repro/g9,EQUAL,,equal                             (was differ:line(2))      § bodyTypeParamChainBorrow278
    r11v45repro/v2,EQUAL,,equal                             (was differ:line(2))      § bodyTypeParamChainBorrow278
    r11u20repro/t6,EQUAL,,equal                             (was differ:fullname(2))  § ifaceElabTypeParamIsDefObj278
    r11u47repro/branches/g9,EQUAL,,equal                        (was differ:fullname(2))  § ifaceElabTypeParamIsDefObj278
    r11v47repro/branches/v7,EQUAL,,equal                        (was differ:fullname(2))  § ifaceElabTypeParamIsDefObj278
    r11v53repro/grid/x10_iface_import_shadow,EQUAL,,equal   (was differ:fullname(2))  § ifaceElabTypeParamIsDefObj278
    v11u113repro/grid/f2/t03_iface_tp,EQUAL,,equal          (was differ:fullname(2))  § ifaceElabTypeParamIsDefObj278

The four changes (all toward golden, chain-keyed away census 0 on each):

    r10uvm92repro/v92_b2_varsel        differ:fullname(21) -> differ:col(2)         § trailIdxVarSelNamesByPath278 (15 firings; the
                                       20 var_select full names cleared, the head now a hier_path element's column, ExprEmit, residue 4)
    r11u107repro/grid/t13_iface_tp_struct  differ:fullname(13) -> differ:fullname(11)   § ifaceElabTypeParamIsDefObj278
    r11u18repro/t4                     differ:line(6) -> differ:line(2)             § ifaceElabTypeParamIsDefObj278
    r11v47repro/branches/v12               differ:fullname(4) -> differ:fullname(21)    § bodyTypeParamChainBorrow278

v12 is a count that grows on the same first field: its first record is unchanged (#9, the struct member reference
`<in>x`, golden `work@dut.I.x`, ours `x`: the sister's struct-member full name), and the pristine walk DIVERGED at #24
(golden `struct_typespec` 3:25, ours `logic_typespec` 4:25: the body chain `b_t = a_t` not borrowed, `objects 207 vs
151`); with the borrow the walk no longer diverges (the object counts agree) and reaches the same struct member
references under b_t and c_t, which carry the same sister face (17 more records of it). Chain-keyed away census on
v12: away 0, flat away 0 (the probe movers' census, below).

## The laws

### § trailIdxVarSelNamesByPath278 (ExprEmit `trailIdxNestedNames187`) — `R11U278_TRAILVARSEL_OFF`

A multi-level select (`m[1][2]`, a UHDM `var_select`) inside a path's trailing select index is named by the path, like
the one-level selects § trailIdxSelNamesByPath187 already names: Surelog stores no full name on it, and UHDM's
ComputeFullName (templates/BaseClass.cpp) keeps the trailing `bit_select`'s name above it (only a `ref_obj` child
skips a `bit_select`, an `indexed_part_select` or a `hier_path`) and keeps the `var_select`'s own name above everything
below it (a `var_select` is never skipped). Golden `q.f[m[1][2]]`: `work@top.q.f.f.m`; `q.f[n + m[1][2]]`:
`work@top.q.f[n + m[1][2]].f.m`; a reference inside it, `q.f[m[k][2]]`: `work@top.q.f.f.m.k`; a part select inside it,
`q.f[m[1][4:0]]`: `work@top.q.f.f.m.m`; a class method `work@c::get::q.f::f::m`. Ours stored the scope's
`work@top.m` (the var_select was the one select kind the walk did not enter). The new branch renames the var_select and
walks its expressions with its own name as the path (a `ref_obj` there is renamed, with its own `ref_typespec`).
Trace `TRAILVARSEL <name>` on every rename.

### § elabPkgQualRefRhsPkgTs278 (ParamEmit `patchParamTypespecs`' default branch + the end of `drainShareDefParamTs`) — `R11U278_PKGQUALRHS_OFF`

An untyped parameter (no type, no dimension, no signing) initialized by a package-qualified name of an untyped
package parameter (`parameter K = p::A;`, a localparam, a header default, `(p::A)`, a macro-born name) types its
ELABORATED param_assign Rhs constant with that package parameter's own typespec. Surelog's elaboration reduces the
initializer through CompileHelper::getValue's qualified-name branch, which hands back the package param_assign's Rhs
constant, ref_typespec and all: golden r10v201repro v201_k_neg binds `p201vk::K_A`'s implicit int_typespec (4:3-4:21)
where ours bound K_PKGR's own (9:3-9:33); a chained package parameter `A = B` binds A's own (K/k14, whose typespec
exists in the elaborated package listing only, so the drain reads the definition listing's `pkgParamObj` first and
the elaborated listing's `pkgParamObjTop` second), a two-package chain `q::A2 = p::A` the named package's (k22). The
reference is recorded in `patchParamTypespecs` (the default branch, after `shareDefParamTs` registers it) and re-bound
design-final at the end of `drainShareDefParamTs`, after every share. Not this law: the definition view; a bare
imported name (`import p::*; parameter K = A;`, already the package's object, k05); a typed, ranged or signed
parameter on either side (k02 already golden's; k03, k08, k23, k24 stage 1 on both binaries); an override (k09);
a real value (k12). A string value (k11, an integral value to slang) and a sized literal (k13) fire and move toward
golden by 1 and 4 records, stage 1 on both binaries. Trace `PKGQUALRHS <ref full name> <package parameter>` where the link changes, `PKGQUALRHS
abstain no-ts` where no listing has a typespec.

### § bodyTypeParamChainBorrow278 (ParamEmit, the type-parameter loop of `emitParameters`) — `R11U278_BODYCHAIN_OFF`

§ typeParamChainBorrow45's borrow for a type parameter declared in a module, interface or program BODY (`localparam
type b_t = a_t;`, `parameter type b_t = a_t;`, both in one declaration, a body b_t naming a HEADER a_t): golden points
the definition view's b_t at a_t's own typespec object there too (that law's residue R0, measured on r11u45repro g9
and r11v45repro v2; grid cases/T), Surelog's chain resolve in compileParameterDeclaration running for every parameter
declaration. The definition listing reads no default syntax for a body type parameter (`defTypeSyn` is the header's
alone), so the borrow reads the declarator (`TypeAssignmentSyntax::assignment->type`) with § typeParamChainBorrow45's
gates: a bare name, a type parameter of this body already emitted (`chainTs45`), no visible typedef of that name
(§ typeParamChainBorrowShadow45v). Pointed at, not re-parented. Every other body shape keeps its path; a dimension
written on the name (`b_t = a_t [1:0]`, T/t05) is not reached; a PACKAGE chain (T/t03, the loop's package listing)
borrows too and moves 4 records toward golden, still stage 1 on both binaries. Trace `BODYCHAIN <b_t> <a_t>`.

### § ifaceElabTypeParamIsDefObj278 (ParamEmit, the type-parameter loop of `emitParameters`) — `R11U278_IFACETP_OFF`

An elaborated INTERFACE instance lists its not-overridden type parameter as the DEFINITION's own `type_parameter`
object: golden r11u20repro/t6, r11u47repro/branches/g9, r11v47repro/branches/v7, r11v53repro x10 and v11u113repro t03 list
`type_parameter T` under the interface_inst `work@top.u` with the full name `work@ifc.T` at the declaration's span (the
definition listing's object), where ours minted an unlocated `work@top.u.T`; its typespec is the definition's default
object, which `typeParamElabTs` now records for the instance. An override gets its own (I/i03 and i13's second
instance, already golden's), a module instance mints its own (I/i07, already golden's); an interface array element, a
generate-scope instance, a nested module's instances, a header or body declaration and a chained default `U = T`
(I/i10, i11, i17, i04, i16, the chained branch of the loop) share the definition's. The definition object comes from
`ifaceDefMap` by name; the law abstains (traced `IFACETP abstain no-def`) when the definition listing has none. Trace
`IFACETP <instance parameter full name>` on every firing.

## Grid (drivers/grid.sh, drivers/case.sh, drivers/gridsum.py; evidence/grid.txt, grid_summary.txt)

99 fresh case dirs, each naming its law in its first line: cases/VS v01-v28 (§ trailIdxVarSelNamesByPath278),
cases/K k01-k35 (§ elabPkgQualRefRhsPkgTs278), cases/T t01-t18 (§ bodyTypeParamChainBorrow278), cases/I i01-i18
(§ ifaceElabTypeParamIsDefObj278); both views (default and `-elabuhdm`), each on pristine, the law, the law +
R11U278_OFF and the law + each switch: **198 case-views, 1386 lines, every line with its exit code; 156 moving, 116
entering STRICT_EQUAL, 0 leaving, 0 exit-code changes; R11U278_OFF gives pristine's bytes on 198 / 198**; every
mover returns to pristine's bytes under exactly one switch (TRAILVARSEL 50, PKGQUALRHS 46, BODYCHAIN 26, IFACETP 32)
except T/t09 in both views (a chain in an interface body: BODYCHAIN and IFACETP act together). Per family: VS 56
case-views, 50 moving, 46 entering; K 70, 46, 34; T 36, 28, 18; I 36, 32, 18. Four uhdm-cmp line changes, all toward:
I/i08 e (stage 1, 33 lines -> STRICT_EQUAL), I/i11 e (83 -> STRICT_EQUAL), I/i15 d and e (446 -> 424, 450 -> 428,
still stage 1: a nested interface's listing). **Away census** (chain-keyed, tools/probe/r11u272repro/drivers/awaychain.py
with strictcmp_x built from tools/probe/r11u272repro/drivers/strictcmp_x.cpp, drivers/awaygrid.sh;
evidence/away_grid.txt): **away 0 and flat away 0 on all 156 movers**; positive control (binaries swapped on VS/v01,
K/k01, T/t01, I/i02) away 2, 1, 16, 2 (evidence/away_poscontrol.txt).

Coverage: the constant slots (K k20 a dimension bound, k29 a replication count, k30 an indexed part-select base,
k31 a generate loop bound, k32 a subroutine default, k35 another parameter's initializer; VS v28 parameter and
operation indices inside the var_select), for-generate, case-generate, if-generate and two-level generate scopes
(VS v06, v15, v16, v17; K k19), instance depths 1-3 (VS v18; K k06, k17, k33), macros (VS v20, K k28), imported
packages (K k05, k26; T t16), the module's own localparams and header parameters (K k04, k27, k35; T t10, t13),
calls as indices and as arguments around the select (VS v19, v21), nested paths (VS v22, declined by
§ trailIdxCallArgNamesByPath187's nested-path test), unpacked selects (VS v23), tasks, functions, an interface body
and classes with `this.` (VS v11, v24, v25, v07, v26), a left-side path (VS v09, stage 1 on both binaries, away 0
toward 0), interface port views, modports and arrays (I i09, i10, i14), interface ports typed by the parameter
(I i12) and typedef defaults (I i18).

Per case (`d` and `e` views, pristine -> law; `(bytes =)` = byte-identical; EQ = STRICT_EQUAL):

| case | result |
|---|---|
| I/i01 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| I/i02 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| I/i03 | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| I/i04 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| I/i05 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| I/i06 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| I/i07 | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| I/i08 | d: rc0 fullname -> rc0 EQ ; e: rc0 stage1(33) -> rc0 EQ |
| I/i09 | d: rc0 stage1(71) -> rc0 stage1(71) ; e: rc0 stage1(71) -> rc0 stage1(71) |
| I/i10 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| I/i11 | d: rc0 fullname -> rc0 EQ ; e: rc0 stage1(83) -> rc0 EQ |
| I/i12 | d: rc0 col -> rc0 col ; e: rc0 col -> rc0 col |
| I/i13 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| I/i14 | d: rc0 stage1(101) -> rc0 stage1(101) ; e: rc0 stage1(101) -> rc0 stage1(101) |
| I/i15 | d: rc0 stage1(446) -> rc0 stage1(424) ; e: rc0 stage1(450) -> rc0 stage1(428) |
| I/i16 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| I/i17 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| I/i18 | d: rc0 stage1(93) -> rc0 stage1(93) ; e: rc0 stage1(93) -> rc0 stage1(93) |
| K/k01 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k02 | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| K/k03 | d: rc0 stage1(91) -> rc0 stage1(91) (bytes =) ; e: rc0 stage1(91) -> rc0 stage1(91) (bytes =) |
| K/k04 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k05 | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| K/k06 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k07 | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| K/k08 | d: rc0 stage1(64) -> rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) -> rc0 stage1(64) (bytes =) |
| K/k09 | d: rc0 stage1(64) -> rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) -> rc0 stage1(64) (bytes =) |
| K/k10 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k11 | d: rc0 stage1(12) -> rc0 stage1(12) ; e: rc0 stage1(12) -> rc0 stage1(12) |
| K/k12 | d: rc0 stage1(64) -> rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) -> rc0 stage1(64) (bytes =) |
| K/k13 | d: rc0 stage1(27) -> rc0 stage1(27) ; e: rc0 stage1(27) -> rc0 stage1(27) |
| K/k14 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k15 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| K/k16 | d: rc0 stage1(17) -> rc0 stage1(17) (bytes =) ; e: rc0 stage1(17) -> rc0 stage1(17) (bytes =) |
| K/k17 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k18 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k19 | d: rc0 stage1(48) -> rc0 stage1(48) (bytes =) ; e: rc0 stage1(48) -> rc0 stage1(48) (bytes =) |
| K/k20 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k21 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k22 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k23 | d: rc0 stage1(51) -> rc0 stage1(51) (bytes =) ; e: rc0 stage1(51) -> rc0 stage1(51) (bytes =) |
| K/k24 | d: rc0 stage1(22) -> rc0 stage1(22) (bytes =) ; e: rc0 stage1(22) -> rc0 stage1(22) (bytes =) |
| K/k25 | d: rc0 stage1(17) -> rc0 stage1(17) (bytes =) ; e: rc0 stage1(17) -> rc0 stage1(17) (bytes =) |
| K/k26 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k27 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| K/k28 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k29 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k30 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k31 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k32 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k33 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| K/k34 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| K/k35 | d: rc0 stage1(17) -> rc0 stage1(17) ; e: rc0 stage1(17) -> rc0 stage1(17) |
| T/t01 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| T/t02 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| T/t03 | d: rc0 stage1(69) -> rc0 stage1(69) ; e: rc0 stage1(69) -> rc0 stage1(69) |
| T/t04 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| T/t05 | d: rc0 stage1(64) -> rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) -> rc0 stage1(64) (bytes =) |
| T/t06 | d: rc0 stage1(68) -> rc0 stage1(68) (bytes =) ; e: rc0 stage1(68) -> rc0 stage1(68) (bytes =) |
| T/t07 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| T/t08 | d: rc0 type -> rc0 EQ ; e: rc0 type -> rc0 EQ |
| T/t09 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| T/t10 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| T/t11 | d: rc0 stage1(148) -> rc0 stage1(148) (bytes =) ; e: rc0 stage1(148) -> rc0 stage1(148) (bytes =) |
| T/t12 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| T/t13 | d: rc0 col -> rc0 EQ ; e: rc0 col -> rc0 EQ |
| T/t14 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| T/t15 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| T/t16 | d: rc0 stage1(72) -> rc0 stage1(72) (bytes =) ; e: rc0 stage1(72) -> rc0 stage1(72) (bytes =) |
| T/t17 | d: rc0 line -> rc0 line ; e: rc0 line -> rc0 line |
| T/t18 | d: rc0 line -> rc0 EQ ; e: rc0 line -> rc0 EQ |
| VS/v01 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v02 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v03 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v04 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v05 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v06 | d: rc0 stage1(148) -> rc0 stage1(148) ; e: rc0 stage1(148) -> rc0 stage1(148) |
| VS/v07 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v08 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v09 | d: rc0 stage1(156) -> rc0 stage1(156) ; e: rc0 stage1(156) -> rc0 stage1(156) |
| VS/v10 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v11 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v12 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v13 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v14 | d: rc0 stage1(156) -> rc0 stage1(156) (bytes =) ; e: rc0 stage1(156) -> rc0 stage1(156) (bytes =) |
| VS/v15 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v16 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v17 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v18 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v19 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v20 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v21 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v22 | d: rc0 fullname -> rc0 fullname (bytes =) ; e: rc0 fullname -> rc0 fullname (bytes =) |
| VS/v23 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v24 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v25 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v26 | d: rc0 EQ -> rc0 EQ (bytes =) ; e: rc0 EQ -> rc0 EQ (bytes =) |
| VS/v27 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |
| VS/v28 | d: rc0 fullname -> rc0 EQ ; e: rc0 fullname -> rc0 EQ |

## Gates (law binary 91d3c653a338aa724023a2c9ae8f0abd; pristine 11861a824c30d2f1e1ea7745b57c9363 = the main tree's build)

- Probe (tests/sweep.sh --corpus probe inside the full sweep): **regressions=0 conversions=11 changes=4** (EQUAL 3814
  + STRICT_NOTEQUAL 273; base 3803 + 284, the pristine sweep's probe.csv byte-identical to results/golden_probe.csv);
  every case uhdm-cmp-equal.
- Surelog: regressions=0 conversions=0 changes=0 (default 478 + 2, testflags 472 + 2); the law sweep's csv differs
  from pristine's only in the LowMemLib / LowMemPkg testflags detail text (the workdir path, environment).
  uhdm2rtlil: regressions=0 conversions=0 changes=0 (803 / 1 / 67 both modes, csv byte-identical to pristine's).
  Both sweeps exit 1 on the law-index staleness check alone (tests/LAWS.md regenerated last, in the patch).
- Downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv byte-identical to pristine's and to
  results/downstream_uhdm2rtlil.csv; **0 of 805 slang-lane databases move**.
- No corpus row is touched, so the uhdm-cmp-at-0-lines gate holds trivially on the corpora; every probe case is
  uhdm-cmp-equal.
- **Firing census** (drivers/tracecensus.sh with R11U278_TRACE over the probe cases and both corpora in both modes,
  the fenced tests excluded by the harness filter built from `$FENCED`; frozen before the law sweep:
  evidence/predict.txt, md5 in predict.md5): **16 lines, all probe, 0 corpus**. **byteverify**
  (fence-filtered hard-link mirrors, tools/probe/r11u272repro/drivers/bvmirror.sh, `tools/probe/r11v75repro/byteverify.sh`,
  SELFCHECK=1): PATH_SETS_IDENTICAL 2560, **MOVERS 0 / 2560**; SELFCHECK reads 2559 / 2560 because every file is
  compared against one fixed file and that file is the one not flagged (pass 201's self-check artefact, not a mover;
  evidence/byteverify_corpus.txt). Probe: **16 of 4087 databases move, exactly the 16 predicted lines** (the 11
  conversions, the 4 changes and r11u45repro/g13, whose two IFACETP firings move its bytes with the strict verdict
  `line(2)` unchanged: the elaborated interface variable typed by the chain, the sister's face below;
  evidence/byteverify_probe.txt). Downstream: 0 of 805 (evidence/byteverify_downstream.txt).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS on both (tools/probe/r11u107repro and
  r10uvm67repro; evidence/canaries.txt). Binary-path audit over the fence-filtered cmds.txt list: 3265 of 3315 name each
  sweep's own frozen binary, the other 50 run no slang (48 carry no slang line, 2, CoresSweRV and CoresSweRVMP
  default, match the audit pattern only through Surelog's own command line; evidence/binary_audit.txt).
- Determinism (tools/probe/r11u272repro/drivers/det.sh, three concurrent draws per row-mode): Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen default and the testflags row-modes with a database: one
  hash each, equal to both sweeps' (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` first): 22 earlier repro dirs (r11u118,
  r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u276, v11u276, r11u274, v11u274,
  r11u45, r11v45, r11u47, r11v47, r10earl29, r10uvm92, r11u115, r11u20, r10v201), both views: **2172 case-views, 2
  moving, 0 entering, 0 leaving, 0 exit-code or uhdm-cmp changes** (evidence/controls*.txt): r11u120repro/grid/gT/
  t08_body_localparam_type d and e (`localparam type e_t = T` naming a header type parameter, § bodyTypeParamChainBorrow278),
  the first record moving from #4 (endline, the body chain's typespec) to #104 (line, the elaborated variable typed by
  the overridden chain, the sister's face below), chain away 0 toward 7 and 6 (evidence/away_controls.txt).
- Downstream on the 99 fresh case dirs (tools/probe/r11u272repro/drivers/dscases.py, both binaries;
  evidence/downstream_cases_*.txt): pristine 83 IDENTICAL, 11 EQUIVALENT, 4 STATUS_DIFF, 1 DIVERGENT; the law 85
  IDENTICAL, 11 EQUIVALENT, 2 STATUS_DIFF, 1 DIVERGENT: **T/t12 and T/t17 move STATUS_DIFF -> IDENTICAL** (the body
  chain's borrowed typespec gives the elaborated variable its ranged type, as Surelog's lane has it), every other
  verdict the same; of the slang lane's 297 `.il`, `_nohier.il` and `_synth.v` files 291 are byte-identical between
  the binaries and the 6 differing are t12's and t17's.

## The probe residue at the base, by writer (evidence/residue_buckets_base.txt, residue_chains_base.tsv, residue_lawfile_base.tsv)

drivers/classify.py + chains.py (from r11u276repro) over the 284 STRICT_NOTEQUAL cases of the base sweep (the first
record's object chain, 165 buckets), and each case's own law (its LAW file or first-line `§`) mapped to the source
file that holds it: 95 cases name a law of this ground only, 123 a law of the sister's ground only, 38 laws of both,
28 no law. The buckets this pass worked: the var_select index names (4 cases: 3 converted, v92 moved), the
package-qualified untyped parameter (v201_k_neg), the body type-parameter chain (g9, v2) and the interface instance's
type parameter (`fullname|type_parameter|interface_inst`, 5 cases, all converted).

## Decodes stopping at the sister's ground (reported, not written)

1. **The received localparam's int_typespec** (3 of the base's 5 `line|int_typespec` cases: r10rgg3repro
   n2_recv_localparam, r10vrgg3repro xc_recv_localparam_only, r11u115repro/grid/i/s01_recv_bodylp): the port view's
   param_assign (`interface_inst p` under the receiving module) holds the receiver's same-named VALUE already
   (ModuleEmit `pvFold115`, § pvRecvShadow115), and golden binds the receiver's parameter's TYPESPEC too (s01: `int`
   at 8:14, the receiver's `localparam int A = 5`, where ours keeps the interface declaration's 1:27). The fix sits
   in `pvFold115` beside the value write (ModuleEmit).
2. **A program instantiated twice** (7 cases: r11u105repro k40, k42, r11v105repro v13, v22 at
   `fullname|ref_obj|assignment|initial|program`; r11u95repro a22, c13, r11v95repro x5 at `fullname|begin|initial|program`):
   golden names the definition program's process objects after the LAST instance (`work@dut.u_q.a`, ours the first's
   `work@dut.u_p.a`); the laws there are UhdmExporter § caProgramNamesakeKeyAtEntry105 and ModuleEmit
   § caProgTaskFuncInstIsElab95.
3. **The elaborated chained type parameter's variables** (r11u45repro g10, g12, g13, r11v45repro v6, v7, v9; grid
   T/t09 e, T/t14, the control t08 above): golden's elaborated chained parameter keeps the DEFAULT chain object
   (r11u45's R2, `b_t = a_t` with a_t overridden still `logic` 4:26) and a variable typed by it takes that object;
   ours already lists the parameter right but types the variable with the override (logic) or a use-site mint (real,
   int in g12: the `real_var b` at 8:10 against golden's 5:26). The variable typespec consumers of
   `typeParamElabTs` / `typeParamDefaultTs` are TypeEmit and ModuleEmit.
4. **A variable typed by an interface instance's type parameter** (grid I/i01, i05, i12): with
   § ifaceElabTypeParamIsDefObj278 the instance lists the definition's parameter, and `typeParamElabTs` holds the
   definition's default object, but the variable `T x` in the elaborated interface is still typed by a use-site
   mint (2:3) where golden shares the default (1:36); the consumer is TypeEmit.
5. **The elaborated continuous assignment's copy of `K`'s value** (grid K/k15, k27: `assign o = K` with `parameter
   K = p::A`): golden's cont_assign constant is typed like the param_assign Rhs (the package's typespec); ours is a
   separate constant parented at the cont_assign at the initializer's span (2:48) whose typespec is K's own. Neither
   binding the Rhs at patch time nor routing the references parked through `bindOrParkParamTs` reaches it (both
   measured, byte-identical to the law's database, and dropped); the writer is outside `patchParamTypespecs` and the
   park list, most likely ModuleEmit `emitContAssigns`' whole-right-side parameter read (not located by a backtrace).
6. The anonymous aggregate type parameter's member full names (r11u47repro g10, g12, r11v47repro v12, `<in>x` named
   `work@dut.I.x` in golden after the value parameter that uses the type: TypeEmit's struct-member names) and the
   r11u69repro select-left-side generate folds (ModuleEmit § caStructParamGenScopeSubst69, 4 cases).
7. Standing as pass 276 reported them: the doubled for-generate part-select base name (TypeEmit emitSyntaxExpr from
   ModuleEmit emitDefGenStmts, 4 cases), the elaborated cont_assign call fold (ModuleEmit emitContAssigns, 6 cases),
   the whole-constant XOR right side, the q2::row_t / home48 alias chain and the struct-member full names (TypeEmit),
   the type-parameter array faces (UhdmExporter).

## Residues, ranked (this ground)

1. **The generate-scope fold reference names** (4 cases, decoded here into four distinct faces, none written):
   r10earl47repro/a3_earl47, a LEFT-side indexed part-select base `p_lhs[LPX +: 4]` in a nested for-generate, golden
   names the folded constant's reference through the select (`...gen_y[0].p_lhs`: the constant parented at the
   indexed part select) where ours names the owning scope `gen_x[0]`; r10earl_repro/vo, a member path's indexed part
   select `st.addr[BW +: 1]` with a package parameter, golden `work@votop.u.st.addr[16+:1].addr` (named through the
   path) against ours `work@votop.u`; r11u112repro/grid/v/v08_comb, an always_comb in a for-generate reading a module
   parameter as an indexed width, golden `work@top` (the declaring module) against ours `work@top.g[0]`;
   r10vearl105repro/v7_repl105, a generate cont_assign reading a module localparam, golden `work@v7_repl105.u_leaf`
   against ours `...u_leaf.gen_r[0]`.
2. **The formal-typespec re-point in a generate index fold** (v11u112repro/grid/brk/f/g1k_hop_userfn,
   `a[f(L)+1]` in an if-generate inside a for-generate with a module function `f(int v)`): golden types the
   generate scope's `L` constant with the function's formal `int` (2:28, ExprEval::evalFunc's
   `exparg->Typespec()->Actual_typespec(tps)`), ours with L's own `int unsigned` (4:16); § caCallArgParamFormalTs232
   stamps only package functions in module continuous assignments.
3. The var_select law's leftovers: r10uvm92repro/v92_b2_varsel's new head (a hier_path element select's start column,
   `bb.two_d[1][2]` at 51:27 in golden, 51:24 ours, `differ:col(2)`), r10earl29repro b1_sites (the same element
   column), b3_edges (a constant's reference name through the path), v8_sites2 (a nested instance's path prefix) and
   v10_str (a struct member's end column).
4. The package-qualified parameter's leftovers: the continuous-assignment copy (reported above, item 5), typed or
   ranged package parameters (K/k03, k08, k13), a real (k12) and a generate-scope localparam (k19), all stage 1 on
   both binaries.
5. The body chain's leftovers: a package chain (T/t03, moved toward by 4 records, still stage 1 on both binaries),
   a dimension written on the name (t05, stage 1) and a typedef of the same name (t06, stage 1;
   § typeParamChainBorrowShadow45v abstains as designed).
6. Items (2) to (7) of the brief beyond the above were not attempted: pass 276's call shapes and call homes, pass
   274's unary and member-read leftovers, pass 272's converted value and module-local function sources, pass 270's
   inside-set range bounds / call index / enum-alias shapes, pass 268's macro shapes, passes 266-232's lists and the
   decode's BuildUVMPkg clusters.

## Process

Fence: every corpus path list was filtered by `$FENCED` (word boundary) before any file was opened (controls.sh,
bvmirror.sh, the binary audit, the byte comparisons of the probe and downstream trees, which hold no fenced name); the
census ran with the harness filter built from `$FENCED`; no fenced source, database or cmds.txt was read or
dispatched outside the gate sweeps. Every tool variable was checked with `[ -x ]` (the env file
`/tmp/r11u278_env.sh` refuses to load without them). No process of another agent was signalled; the one process
listing (`ps -eo pid,args | grep '[r]11u278_swL'`) was filtered to this pass's own workdir name, to confirm the law
sweep started. Superseded binaries law1-law7 (the var_select law alone; the package law before the elaborated
listing fallback; two experiments for the continuous-assignment copy, measured and dropped; the interface law before
its chained branch); the census, grid, controls and both sweeps ran on the final one (law8 = law.bin). The main tree
was not written.

Files: drivers/case.sh, grid.sh, gridsum.py, awaygrid.sh, controls.sh, ctlsum.py, tracecensus.sh, classify.py and
chains.py (from r11u276repro); the away census (awaychain.py with strictcmp_x), bvmirror.sh, det.sh and dscases.py
are used in place from tools/probe/r11u272repro/drivers.
