# The fenced tests

Four corpus tests are fenced. This file is the record of their names and of
the design notes that name them. The exporter source refers to them by the
tags below and holds no fenced name.

## The names

| Tag | Test |
|---|---|
| F1 | `UnsignedParam` |
| F2 | `HierPathEval` |
| F3 | `FileLocalParam` |
| F4 | `TopParam` |

The machine-readable list is the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh`. Every script reads the names from that
line and refuses to run without it.

## The rules

- No pass opens, runs, debugs or decodes a fenced test: not its sources, not a
  copy of its sources, not its databases in a sweep directory.
- The gate sweep dispatches every row itself. Its csv verdicts are the only
  facts about a fenced test that a report may cite.
- A script that reads corpus sources or corpus databases excludes the four
  tests by word boundary.
- A pass does not spell the names in a shell loop, a command line or a report.
  It reads them from the `FENCED=` line. A longer test name that contains a
  fenced name as a substring is a different test.
- A landing scans its patch and its evidence directories for the names by
  whole word. The count must be 0.

## Why they are fenced

Each of the four diverges inside slang itself, before the exporter runs: slang
and Surelog evaluate a constant differently, and the value selects a generate
branch or a design top. The exporter cannot reach that decision. The notes
below give the mechanism per test.

## The design notes moved from the source

These notes were comments in the exporter source until 2026-09-29. The source
keeps each note with the tag in place of the name. The line numbers are those
of the commit that moved them.

### `src/UhdmExporter.cpp` lines 11352 to 11359

```
// NOTE (design-root family, TopParam): a module whose parameter has NO
// default (`module top #(parameter param);`) is a design top for Surelog
// (design `work@top`, TopModules = [top], the child getting an overriding
// param_assign whose Rhs ref_obj resolves to top's own unset parameter),
// but slang refuses it both automatically and under an explicit --top
// ("'top' is not a valid top-level module"), so orderedTops comes back
// empty and the design falls to `unnamed` with a null TopModules. Not
// reachable without a slang change; the AllModules def views already match.
```

### `src/UhdmExporter.cpp` lines 11517 to 11538

```
// Modules instantiated ONLY inside a non-taken generate branch: slang never
// reports them as unreferenced, but Surelog still compiled them, so they
// carry the same def-view-only entry in AllModules. A def added here can
// itself hide further non-taken branches, so run to a fixpoint over a
// snapshot (collectDefs keeps appending to uninstGenDefs).
//
// NOTE (design-root family): this closes the design ROOT of HierPathEval
// and UnsignedParam, both of which then diverge on CONSTANT EVALUATION,
// not on containers:
//   * HierPathEval — `.PadType(TargetCfg.dio_pad_type)` where TargetCfg is
//     a 2-bit packed struct {logic a; pad_type_e dio_pad_type} = 'b10.
//     slang folds the member select to 0 (first member is the MSB, per
//     LRM); Surelog folds it to 1. Matching golden means reproducing
//     Surelog's LSB-first member offset for this fold — do not do it
//     globally, it would break every converged packed-struct fold.
//   * UnsignedParam — `localparam signed [63:0] n` gives golden an
//     int_typespec with vpiSigned:1 that we do not set (a real, separate
//     gap), and beyond it `n4 == 10376293541461622783` is TRUE for Surelog
//     (64-bit unsigned) and FALSE for slang (the unsized decimal needs 65
//     bits as a SIGNED value), so the `GOOD good();` generate branch is
//     taken in golden's topModules and not in ours. Not reachable without
//     a slang change.
```

### `src/ExprEmit.cpp` lines 40912 to 40930

```
// NOTE (HierPathEval, design-root-class triage): when the BASE is a
// packed-struct CONSTANT, golden's VALUE cannot be reproduced here.
// UHDM's ExprEval::hierarchicalSelector (ExprEval.cpp, the
// `constant` + `struct_typespec` arm) accumulates the member offset
// `from` in DECLARATION order starting at bit 0 — the FIRST member
// at the LSB — which is the reverse of SV packed-struct layout. For
// `struct packed {logic a; pad_type_e dio_pad_type;} TargetCfg = 2`,
// golden reads `TargetCfg.dio_pad_type` as bit 1 = 1 where slang
// (correctly) gives bit 0 = 0. That wrong value then flips a
// generate condition INSIDE slang's own elaboration (the true arm
// instantiates a module we never see), so the divergence is not
// reachable from the exporter: it would take slang adopting
// Surelog's layout. HierPathEval is blocked on that, not on naming.
//
// § thisDeepStepMockupConst84 — SITE 4 of 4, the NO-CALL, NO-SELECT
// spelling: a plain nested member read (`this.cfg.n_bytes`,
// `this.value.value`, `this.__m_uvm_status_container.status` — 15
// more source sites per UVM database, CENSUS Part 2).  ONE step
// (`this.n`) is not a mockup and the predicate declines it.
```

### `src/ParamEmit.cpp` lines 9796 to 9840

```
// ELAB view: `parameter DEBUG = Cfg.NoSlvPorts` — an init that
// READS a struct param's MEMBER — reduces against that param's
// ELABORATED Rhs. Surelog's reduceExpr walks the hier_path into
// the base parameter's own elab value and hands back the member
// slot verbatim: the flattened op75's operand (already at the
// member width), or, when the base's elab Rhs is a whole-struct
// CONSTANT ('0), that constant unchanged. The result carries the
// READ's span and nothing else — no typespec.
// The DEF view keeps the symbolic hier_path (a parameter PORT has
// no value there), which is what the fold-chain guard below still
// covers. Probe matrix (base init form x view,
// /tmp/r9tsfin/q1..q4, Surelog -elabuhdm):
//   port param = '0        -> def hier_path, elab INT:0 size 96
//   port param overridden  -> def hier_path, elab UINT:5 size 32
//                             (NoReducTypespec)
//   body param = '{x:16}   -> BOTH views fold (own fold path)
//   body param = cast'(16) -> BOTH views keep the hier_path
//                             (u2r *OfInstanceInitializedBy-
//                             StructMember, unchanged)
// ...and only for the parameter's OWN declared init: an OVERRIDE
// ACTUAL that reads a struct member (#(.PadType(TargetCfg.dio_pad_type)))
// keeps the symbolic hier_path at the override site — Surelog folds
// the declaration, never the connection (u2r ParameterPassedTo*,
// ParameterFromPkg*, the ovMemberInitParam model below).
// NOTE (r10sing3, decoded — NOT implemented, no reachable mover yet).
// Surelog's OWN packed-struct member extraction from a CONSTANT base
// assigns member offsets in DECLARATION order FROM THE LSB, i.e. the
// REVERSE of the LRM (where the first-declared member is the MSB).
// Probe r10sing3 g3 (`struct packed {logic[3:0] a; logic[7:0] b;
// logic[1:0] c;}`, P = 14'hABCD, read through `sub #(.PA(P.a),
// .PB(P.b), .PC(P.c))`): Surelog gives 13 / 188 / 2, which is
// value[3:0] / value[11:4] / value[13:12] — LSB-first. The LRM answer
// (10 / 243 / 1) is what slang computes.
// Two more facts from the same probe pair:
//  * the OVERRIDE path reduces the select (constant at the FORMAL's
//    default span, vpiSize = the formal's width, ConstType 9);
//  * a member select in a plain same-scope param_assign does NOT
//    reduce at all (probe g2): Surelog hands back the BASE struct
//    constant verbatim (HEX:ABCD, decompile 14'hABCD, ConstType 5,
//    ts ref -> the struct typespec) with only vpiSize replaced by the
//    LHS parameter's width.
// HierPathEval needs the first law, but it is NOT reachable from the
// emitter: the value it changes also decides which generate branch
// slang elaborates (`PadTypeInGeneric == 1`), and that decision is
// made inside slang's compilation, not here. Ranked as slang-blocked.
```

### `src/EmitHelpers.h` lines 2045 to 2053

```
// Collects one representative instance per definition, recursively.
// `uninstDefNames`, when given, additionally collects the DEFINITION NAMES
// reached only through a NON-TAKEN generate branch: Surelog compiles every
// parsed module, so such a module still carries a def view in
// design->AllModules (HierPathEval: work@GOOD, referenced only from
// gen_inner_if_true, which is false). slang marks those definitions referenced,
// so getUnreferencedDefinitions() never reports them, and inside an
// uninstantiated scope the instantiation is an UninstantiatedDefSymbol that
// carries only the NAME -- hence names, resolved by the caller.
```
