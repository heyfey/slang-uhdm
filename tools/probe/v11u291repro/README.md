# v11u291 — adversarial verification of r11u291 (module/type ground)

Base 309b62bc (pass 289). Verdict: **ACCEPT WITH FIX**. The three laws of r11u291 reproduce bit for bit, but
§ tpUseSigBindsTpObj291 breaks legal SystemVerilog in three shapes its grid did not cover. Pristine was right on
records the law moves away, and one case goes downstream EQUIVALENT -> STATUS_DIFF. One of the three shapes is an
EARLIER evidence case: tools/probe/r11u20repro/t9 reads chain away 3 in both views. Three refinements inside the law
fix them, behind `src/R291.h` (`r11v291On`):

| switch | law | the break it fixes |
|---|---|---|
| `R11V291_BODYTD_OFF` | § tpUseBodyTdTargetAbstains291v | a target naming a typedef the BODY declares (`typedef logic [3:0] lt; localparam type T = lt;`, also through a chain `T = A`, `A = lt`, and an enum typedef): golden binds the typedef's own typespec `lt`. VT/vt08 chain away 3 and downstream EQUIVALENT -> STATUS_DIFF; vt23 away 4; vt32 away 8; **r11u20repro/t9 away 3** (`localparam type PD = vec_t`) |
| `R11V291_CLASSTP_OFF` | § tpUseClassTargetAbstains291v | a type parameter whose target is a class (`parameter type T = pk::c; T h;`): golden lists the class_typespec at the target's spelling. VT/vt05 away 1 and 4 (elaborated view) |
| `R11V291_GENSHADOW_OFF` | § tpUseGenShadowAbstains291v | a generate-local `localparam type T` shadowing the body's T, in the signal's own block or an enclosing one. Golden types `g.v` with the local `logic [1:0]`; the law bound the body's 3-bit `pk::w_t` to a 2-bit signal. VT/vt04, vt25: our gen_scope lists no local type_parameter, so the law cannot bind golden's object |

Each switch restores the law's bytes on exactly its own witnesses. `R11V291_OFF` gives the law's bytes and
`R11U291_OFF` still gives pristine's bytes, on 128 of 128 fresh case-views and 212 of 212 of the implementer's.
**The fix binary's gate sweeps are byte-identical to the law's**:

- 0 of 3365 corpus databases and 0 of 4087 probe databases differ;
- the csvs are identical but for the LowMem detail path;
- the fix firing census was frozen before the fix sweep and predicted 0 movers (no `genshadow`, `class` or `bodytd`
  abstention fires on any gate database). The positive control: all three tags fire on vt04, vt05 and vt08.

So every gate number and every conversion of r11u291 stands for the fix.

## Reproduction (binaries built by the verifier in fresh worktrees at 309b62bc, frozen read-only)

- pristine f285f238dbd51f0029dc79812e56e69d: equal to the main tree's build at the base.
- law c3b84092d573fedf1aac730cdd76a1d6: equal to the implementer's (the patch applies cleanly).
- fix 71677272c3f78e3ba89b23242631413c.
- slang 12.0.0+545f88b2e. Every sweep ran `tests/sweep.sh --jobs 3` with its own frozen binary exported
  (evidence/sweep_P.log, sweep_L.log, sweep_F.log). The pristine sweep exited 1 on the law-index check alone.

| stage | pristine | law | fix |
|---|---|---|---|
| probe | 3903 + 184, 0/0/0 | **3922 + 165**, regressions 0, conversions 19, changes 0 | the same, probe.csv byte-identical to the law's |
| surelog | 478 + 2 / 472 + 2, 0/0/0 | the same, csv equal but for the LowMemLib/LowMemPkg workdir path | the same |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | identical csv | identical csv |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0, csv = results/downstream_uhdm2rtlil.csv | identical | identical |

- The 19 probe conversions read the same by name and first field as the implementer's table (sweep_L.log).
- Firing census (the implementer's drivers/tracecensus.sh on my law binary, frozen before my law sweep;
  evidence/predict_law.txt): byte-identical to the implementer's predict.txt (24 lines).
- byteverify on fence-filtered hard-link mirrors (8 fenced row-mode databases left out; evidence/byteverify_corpus.txt):
  - pristine -> law: exactly the 2 predicted movers, surelog TypeParam d/t. Both stay CMP_EQUAL, with away.py lost 0
    and awaychain.py chain away 0 / toward 0.
  - law -> fix: 0 of 3365.
  - pristine -> fix: the same 2.
  - SELFCHECK 3363 of 3365 (the known twin).
- Probe bytes (the pristine and fix probe stages rerun from the law worktree, because probe databases embed the
  worktree path; evidence/byteverify_probe.txt): pristine -> law exactly the 22 predicted (the 19 conversions plus
  r11u18 t1, t9 and r11u20 t8, EQUAL on both). law -> fix 0.
- uhdm-cmp: 0 lines on every touched row (TypeParam d/t CMP_EQUAL, every conversion EQUAL).
- Canaries: surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0 on all three sweeps; ctcan2 PASS on both csvs
  (EXPECT_UNKNOWN=1 and 6) on all three.
- Binary-path audit (fence-filtered cmds.txt lists): on each sweep, 3265 of 3315 name that sweep's own frozen binary.
  The other 50 run no slang. Two of them (the CoresSweRV rows) match "slang-uhdm" only through the repository path
  in Surelog's own command line.
- Determinism (evidence/determinism.txt): three concurrent draws per row-mode with the law and with the fix on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Each gives one hash per row-mode,
  equal to the law sweep's; Scoreboard and Rggen testflags write no database, as at the base.
- The implementer's grid (89 case dirs + 19 probe targets, 216 case-views; evidence/grid_impl_repro.txt):
  - identical to evidence/grid.txt in every field but the md5, which embeds the worktree path;
  - 168 moving, 144 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes;
  - switches TPUSEOBJ 84, ANONMEMBNAME 42, CLSSPECDECL 42; R11U291_OFF = pristine on 212 of 212 compared
    (b25 and c19 exit 3 on every binary);
  - the fix moves 0 of 212 against the law.
- The implementer's byte controls (the same 30 dirs, 1550 case dirs, 3100 case-views; evidence/controls_impl_*):
  - 68 moving, 14 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes;
  - the uhdm-cmp 51 -> 0 on r11u281 TI/i03 and v11u281 vi17 and vi42;
  - chain away 0 and lost 0 on all 68, 210 records toward golden;
  - law -> fix 0.

## Widened byte controls (evidence/controls_wide_*; 26 more dirs, 1984 case dirs, 3968 case-views)

The 26 dirs: r11u289, v11u289, r11u287, v11u287, r11u285, v11u285, r11u283, v11u283, r11u279, v11u279, r11u277,
v11u277, r11u271, v11u271, r11u269, v11u269, r11u20, r11u90, r11v88, r11u131, r11v131, r11u124, r11v124, r11u118,
r11v11u118 and r11u119. Every path list was filtered by $FENCED before any case was opened.

- **pristine -> law: 10 moving, 0 leaving, 0 exit-code changes.**
  - **tools/probe/r11u20repro/t9 reads chain away 3 in both views**: `localparam type PD = vec_t;` with
    `typedef logic [WA-1:0] vec_t;` in the body, the BODYTD break on an earlier evidence case.
  - The other 8 (r11u285 C/c05_union, v11u285 VC/vc15 and vc19, v11u287 VP/vp05, both views) move toward golden
    inside stage 1: chain away 0, toward 2 to 12.
- **law -> fix: exactly t9 d/e, back to pristine's bytes** (BODYTD).
- **pristine -> fix: 8 moving, chain away 0 on all.**

## Attack (64 fresh case dirs, 128 case-views, every line with its exit code; cases/, evidence/grid_fresh*)

Each dut.sv names its law in its first line; the witnesses of the refinements name the refinement.

**VT — § tpUseSigBindsTpObj291 (38 cases).** Shapes:
- top-level type parameter (the definition-view and elaborated full names collide; vt01, vt02);
- an instance array (vt03);
- generate-local shadows (vt04, vt25 → § tpUseGenShadowAbstains291v; vt29 a generate-local typedef);
- class targets (vt05, vt24, vt28 → § tpUseClassTargetAbstains291v);
- `T [1:0] v` in an interface and a module (vt06, vt07);
- body typedef targets (vt08, vt23, vt32 → § tpUseBodyTdTargetAbstains291v), a typedef passed down (vt31);
- a package enum port (vt09);
- interface declarations with an initializer (vt10), in a for-generate (vt11), in the port list (vt13);
- a chain under an override (vt12);
- an escaped instance name (vt14);
- a non-ANSI redeclaration (vt15);
- two declarators with initializers (vt16);
- an uninstantiated definition (vt17);
- if- and case-generate blocks (vt18, vt37);
- signed keyword types in an interface (vt19);
- a wildcard-imported module with a qualified default (vt20);
- two levels with qualified overrides (vt21);
- an interface in a generate block (vt22);
- real, string and virtual-interface targets (vt26, vt34, vt33);
- a package struct (vt27, vt36);
- an interface chain `U = T` (vt30);
- `int signed` (vt35);
- two interface instances through a modport (vt38).

**VA — § anonAggMemberChainName291 (12 cases):** an int-base enum, a generate typedef, two instances, an interface
modport, a signed struct with a union array, a top-level variable written by always_ff or by an initializer, a
package typedef, a typedef of an anonymous array, a direct-member control, a class member, and a localparam.

**VC — § clsSpecDeclNameSpan291 (14 cases):** qualifiers, multi-line named arguments, class-parameter arguments,
array, queue and dynamic properties, a fork-block local, a macro type, a nested specialization type argument, a
program class, wildcard and named imports, a same-package property, an initial-block local, two declarators with
`#()`, and an interface class.

Results:

- **law: 92 moving, 0 leaving STRICT_EQUAL, 0 exit-code changes.**
  - 7 case dirs read chain away (the three breaks above). vt08's downstream goes EQUIVALENT -> STATUS_DIFF.
  - vt04 and vt25 bind a 3-bit object to a 2-bit signal (away 0 only because pristine's location is wrong too).
- **fix: 84 moving (pristine -> fix), 58 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.**
  - chain away 0 on all 84, 535 records toward golden;
  - uhdm-cmp 51/53 -> 0 on vt13, vt19, vt22 (stage 1 -> STRICT_EQUAL or col);
  - law -> fix 14 case-views, each restored to pristine's bytes by exactly one switch (BODYTD 6, CLASSTP 4,
    GENSHADOW 4); vt28 is identity only.
- Positive control (binaries swapped, evidence/away_poscontrol.txt): chain away 1 to 18 on 8 of 8.
- Downstream (evidence/downstream_fresh.txt, 64 dirs on pristine, law and fix; the 6 round-3 dirs added later):
  - the fix improves 13 dirs and makes none worse than pristine:
    - DIVERGENT -> IDENTICAL: vt11, vt13, vt22, vt30;
    - STATUS_DIFF -> IDENTICAL: vt18, vt19, vt37, vt38;
    - EQUIVALENT -> IDENTICAL: vt01, vt03, vt12, vt14, vt21.
  - The law's vt04 and vt25 STATUS_DIFF -> EQUIVALENT came from the wrong-width binding; the fix gives it up.

## What the law gets right (confirmed)

Surelog's CompileType.cpp, at the end of the NamedType case of compileTypespec, resolves a name that no earlier branch
resolved through `component->getParameters()` to `type_parameter->Typespec()->Actual_typespec()`, with no copy.
That holds for a type parameter whose target is a qualified package typedef or a keyword type, and the packed
dimensions written on the use are dropped (vt07 converts). It does not hold where an earlier branch resolves the name
first: a body typedef, a class, or a generate-local declaration. That is what the three refinements encode.

## Residues (ranked; all wrong on pristine too)

1. The implementer's list stands: imported `.T(w_t)`, `var T`, `.T(T)`, ordered overrides, programs, unpacked dims;
   law 2's n01, n02 and n10; law 3's type arguments c07 and c17 (fullname; my vc07 the same face). The located
   faces vx8/v14, q04, y62, y31/x36, a4_corpus/a6_headerforms and a36 are not written.
2. The refinements' shapes, now at pristine's bytes:
   - a generate-local type parameter (vt04, vt25): our gen_scope lists no local type_parameter. Golden binds its
     object, `logic [1:0]` at the local spelling. Write the gen_scope's type_parameter listing (ModuleEmit
     emitGenScopes), then bind it.
   - a body typedef target (vt08, vt23, vt32, r11u20 t9): golden binds the typedef `lt` itself. A twin law binding
     the body typedef's listed typespec is the fix.
   - class targets (vt05, vt24): stage 1 on every binary.
3. Fresh shapes the laws move toward golden but do not finish (stage 1 or strict on every binary, chain away 0):
   - VA: va04 (interface modport, exit 4 on every binary), va05 (fullname), va07, va08, va09, va12, va11 (endcol);
   - VT: vt06 (an interface `T [1:0]`, unmoved), vt10 (endcol), vt11, vt14 (the escaped instance name's end
     column), vt27, vt29, vt31, vt33 (STATUS_DIFF downstream on every binary).
4. Sister ground: none new; the implementer's list stands.

## Process

- The fence was read fail-closed from tools/probe/r11u107repro/canaudit.sh through the implementer's
  drivers/env.sh and never spelled in a command.
- Every corpus path list (mirrors, audit, controls) was filtered by word boundary before any file was opened.
- No decode touched a corpus source or database: the corpus away census ran only on TypeParam, a non-fenced mover.
- No other agent's process was listed or signalled. The main tree was not written.
- All scratch is under v11u291-prefixed /tmp paths.
- Draft binaries: one (fixd1, the same bytes as the delivered fix). Every fix measurement is on the frozen fix.
- **The verifier's slip, no effect:** the 1550-dir and 1984-dir controls ran with the fix copy named `fixd1` (byte
  identical to `fix`, md5 71677272). The summaries read that tag.
