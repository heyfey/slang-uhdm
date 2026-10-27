# v11u443 — adversarial verification of r11u443 (foreach loop variables in instantiated programs and interfaces, the iterated reference of a packed foreach)

Verifier of pass 443 on the expression / parameter ground. Base 3dcbb0b9
(pass 441). Implementer's patch /tmp/r11u443.patch (applies clean on a fresh
3dcbb0b9). Pristine reading: the master's control sweep at the base
(/tmp/intr11u441) and the implementer's frozen base build for case runs (md5
c4efdfa2c713ab09d9d8aada0ba7da74, the base build's md5 named in the brief).

VERDICT: the four laws hold on every corpus row, probe case and sv-tests row
and on 117 of 131 fresh case dirs, but THE PROGRAM LAW BREAKS on legal SV
where pristine was right: § elabProgMemberArrLoopVar443 wrote an array_var
loop variable for program members that Surelog lists as an array_net, where
golden (and pristine) keep the element loop variable. Fixed behind its own
switch as § progStructNetElemKeeps443v (R11V443_STRUCTNET_OFF). Shipped as
/tmp/r11u443.verified.patch.

## Reproduction of the implementer's numbers

- Law binary rebuilt once in /tmp/wt_v11u443 from the patch: md5
  aa7960111f51c88854d70e8d2280d100, equal to the implementer's law4, linking
  slang 12.0.0+545f88b2e (frozen at /tmp/v11u443_bin/law). The uhdm-strictcmp
  build: fa6e4f42f252ae0ab69d9845003e71c5, equal to the implementer's.
- The 65 grid lines (cases in tools/probe/r11u443repro): reproduced exactly on
  exit code, uhdm-cmp count, dump distance and strict verdict
  (evidence/v11u443_impl_grid_pl.tsv; md5 columns differ only because the
  database holds the case's absolute path).
- R11U443_OFF on the verified binary gives pristine's bytes and exit code on
  65 of 65; the verified binary gives the law's bytes on 65 of 65 (the
  refinement fires on none of them).
- Earlier-case census: the implementer's 8 movers outside its grid
  reproduced against fresh Surelog goldens, same verdicts (r11u131repro
  inet/n03_foreach and n07_sub_foreach, r11u439repro UP/up19, v11u439repro
  VP/vp09 and VS/vs09 to STRICT_EQUAL; r11u238repro F/f03 to STRICT_NOTEQUAL
  endcol; v11u280repro VA/va21_foreach_fork 71 -> 68 and v11u439repro VP/vp08
  251 -> 246 closer).
- The one law sweep (below) reads every count the implementer's sweep read.

## THE BREAK (found by the attack grid, cases/VS)

§ elabProgMemberArrLoopVar443 assumes the swap in Surelog's
writeElabProgram always reaches the member's array_typespec. It does only
when Surelog lists the member as an array_var. NetlistElaboration lists some
program members as an array_net, and for those golden's loop variable stays
the element kind:

- a struct type, packed or unpacked, typedef or anonymous, with unpacked
  declarator dimensions (fixed, dynamic, queue, associative, more than one),
  whose every leaf field (nested structs included) is a logic or reg scalar
  or a packed vector of one: `typedef struct packed { logic [3:0] f; } s_t;
  s_t a[3];` lists array_net work@top.p.a, and the loop variable is struct_var
  over s_t (VS/vs02, vs05 to vs08, vs11 to vs14, vs23, vs27, vs32, vs35 and
  VA/va02; the associative VS/vs14 too, where the law took the index
  typespec);
- a net or reg vector array: `wire [3:0] a [3];`, `reg [3:0] a [3];`,
  `wire a [3];` give logic_var over the element (VS/vs36, vs38, vs41).

Pristine was right on the loop variable in every one of these; the law
wrote array_var (and int_var for the associative one). Fourteen case dirs
moved away on the strict axis (pristine -> law): dump distance further on
VS/vs02 26 -> 56, vs07 80 -> 83, vs13 81 -> 84, vs14 93 -> 96, vs36 26 -> 35,
vs38 26 -> 35, and the loop variable cell moving away from golden at the same
distance on VA/va02, VS/vs05, vs06, vs11, vs12, vs27, vs32 and vs35. All
NOT_EQUAL on pristine too (the reads bind an implicit net there), so no
gate row is involved, but each is a strict cell moving from golden's value to
a wrong one.

The distinguisher, from the goldens of 41 VS shapes: a field of any other
kind (int, bit, byte, integer, string, an enum even with a logic base, an
unpacked array, a packed array of a struct), a union, a typedef of the whole
array (`typedef s_t sa_t [3]; sa_t a;`) or a packed array of the struct
(`s_t [1:0] a[3]`) gives array_var in golden, where the law is right
(VS/vs01, vs03, vs04, vs09, vs10, vs15, vs17 to vs22, vs24 to vs26, vs28 to
vs31, vs33, vs34, vs37, vs39, vs40, VA/va30).

## The refinement

§ progStructNetElemKeeps443v (StmtEmit, inside § elabProgMemberArrLoopVar443's
gate; fixOn(443, "R11V443_STRUCTNET_OFF")): the program law abstains, and
the element loop variable stays, when the member's declared type with its
declarator's unpacked dimensions peeled (stopping at a typedef) is a struct
whose every leaf field is a logic or reg scalar or a packed vector of one, or
when this exporter already lists the member as an array_net. The loop
variable then registers under § elabProgLoopVarReadBinds443, so its reads bind
the element struct_var or logic_var as golden's do. lawTrace(443,
"progStructNetElemKeeps443v", ...) logs each firing. No src/R*.h, no getenv,
no reader function, no flag across files; EmitHelpers.h and ExprEmit
unchanged from the implementer's patch.

R11V443_OFF and R11V443_STRUCTNET_OFF give the law's bytes on 131 of 131
attack case dirs and 65 of 65 of the implementer's; R11U443_OFF on the
verified binary gives pristine's bytes and exit code on 131 of 131 and 65 of
65.

The cost, both still closer than pristine: two cases where this exporter's own
listing is an array_net and golden's an array_var lose the law's loop
variable (VA/va27, a dimension over a typedef'd struct array, 100 -> 86 on the
law and 100 -> 93 verified; VS/vs16, an unpacked union, 73 -> 59 law and
73 -> 66 verified). The listing itself is ModuleEmit's (see the sister-ground
faces below). Avoiding this would need a third build, which the budget does
not allow.

## Attack grid (cases/, drivers/grid.sh, evidence/v11u443_attack_grid_plv.tsv)

131 fresh case dirs, every one accepted by upstream slang (~/.local/bin/slang
--single-unit), every exit code 0 on Surelog, pristine, law and verified:

- VA (30): program members: 2-D partial loops, struct, class, queue, dynamic
  and associative arrays (int, typedef'd bit, typedef'd string keys),
  fork, final, ports, a generate-block instance, two module-level
  instances, a parameterized program, nested and same-name nested foreach,
  `$unit` names shadowing the loop variable, initializers, a class inside the
  program, a parameterized `$unit` class's method, two loops reusing a name.
- VB (12): program read binding over non-member names: a class handle
  h.arr, a `$unit` array, an interface port bus.arr, a package array, a
  process-local array, packed and string members, ternary, case and
  compound-assignment reads.
- VI (18): interfaces: two instances, a parameterized width, a generate
  block, an instance array, byte, struct, string, 2-D packed, packed-of-
  unpacked members, final and always blocks, a task body, and wire, reg,
  struct and int-struct arrays.
- VP (30): packed foreach references in modules: int, integer, signed, a
  function local, ANSI output and non-ANSI ports, two declarators, var, 3-D
  packed, ascending, two instances with different widths, a function-local
  string, a packed struct, always_comb, wire, a packed-of-unpacked array, a
  local typedef, two loops, reg, a module variable read from a function, an
  initializer, an interface, a module with a class, a package typedef, a
  named always block, a continuous-assign reader.
- VS (41): the program-member net/var distinguisher (the probe sources and
  their case names in evidence/v11u443_probe_to_case_map.txt).

pristine -> verified (evidence/v11u443_attack_class_p_to_v.txt): 71
NOT_EQUAL -> STRICT_EQUAL, 1 STRICT_NOTEQUAL -> STRICT_EQUAL (VP/vp13, a
packed struct), 8 NOT_EQUAL -> STRICT_NOTEQUAL (VA/va08 and va12 fullname,
pf08's twin with the program under a generate block and under two module
instances; VP/vp09 and vp22 endcol; VS/vs01, vs09, vs28 and vs31), 42 closer by
dump distance, 9 byte-identical (VA/va25 a parameterized `$unit` class's
method, VI/vi12 an interface task, VP/vp04, vp12 and vp17 controls already
STRICT_EQUAL, VP/vp05, vp06, vp14 and vp27 the ANSI and non-ANSI port
residues), NONE FURTHER. The 9 byte-identical cases are exactly the 9 where no
law fires (evidence/v11u443_attack_firings_ver.txt).

pristine -> law (evidence/v11u443_attack_class_p_to_l.txt): the 14 break
dirs above; law -> verified (evidence/v11u443_attack_class_l_to_v.txt): 17
closer (the break dirs), 2 further (va27, vs16, the refinement's cost), 112
byte-identical.

Downstream (drivers/dsgrid.py, evidence/v11u443_ds_*.tsv) on the 126
class-free attack case dirs: pristine and verified 123 IDENTICAL and 3
EQUIVALENT (VI/vi13, vi14, vi18, nohier, on both), no verdict changing.

Determinism: three concurrent verified runs plus the grid run of VS/vs05,
VA/va02 and VS/vs36 read one hash each.

## Away census (drivers/census.sh, evidence/v11u443_census.tsv)

1007 fence-filtered tools/probe .sv / .v files holding `foreach` (widened
from the implementer's 763; the path list was filtered on the fence list
before any file was opened), run on pristine, law and verified: exit codes
equal on all 1007 (2 multi-file sources write no database on any binary),
63 byte movers pristine -> law, the verified binary byte-identical to the law
on all 1007 (the refinement fires on no existing case). Movers: the
implementer's 50 grid dirs and its 8 earlier-case movers (above) plus 5 more
it did not run, each judged against a fresh Surelog golden
(drivers/judge.sh): r10vbuvm33repro/v33a.sv NOT_EQUAL -> STRICT_EQUAL (dump
distance 223 -> 222); r10uvm137repro/g137_c_homes.sv 541 -> 536,
r10uvm211repro/grid211/g211_g_packed.sv 1315 -> 1312,
r10v137repro/v137_e_mult.sv 204 -> 200 and r10vbuvm34repro/v34g.sv 135 -> 117,
closer with the uhdm-cmp count unchanged. None away.

## Sweeps (drivers/fullsweep.sh; each started after three quiet readings, no
other sweep live)

LAW sweep (aa796011, /tmp/v11u443sw1, R11U443_TRACE set, 02:14 to 02:37):
probe EQUAL 4023 + STRICT_NOTEQUAL 64 with 0/0/0 and the csv identical to the
control; surelog 480 + 0 / 474 + 0 with 0/0/0, the csv differing from the
control only in the two LowMem log-path texts, Tnoc d/t CMP_NOTEQUAL standing;
uhdm2rtlil 803 / 1 / 67 in both modes with 0/0/0 and stamped_gen_param d/t
CMP_NOTEQUAL standing; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2
EQUIVALENT / 0 DIVERGENT, csv identical; sv-tests EQUAL 1913, DIFFERENT 27,
BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of
2346 with regressions 0, conversions 0, changes 0 and the csv identical to the
control. byteverify against the control (SELFCHECK=1): 0 of 962, 0 of 1608,
0 of 805 with the self-checks flagging 961, 1607 and 804. The 4087 probe
databases identical to the control by path-normalized dump, with a positive
control (a different database under the same name reads DIFF). Canaries
ok=52 and ok=16 changed=0; ctcan2 PASS on both. Binary audit, fence-filtered:
surelog 1523 of 1573 cmds.txt naming the law binary (the other 50 holding
only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346. Trace
directory empty in all five stages.

VERIFIED sweep (748c900d, /tmp/v11u443sw2, 02:40 to 03:03), prediction
recorded before launch (evidence/v11u443_prediction_ver.txt: the refinement
lies inside a gate that fired nowhere, so 0 firings and every csv equal to the
law sweep's): every count as the law sweep; the probe, uhdm2rtlil, downstream
and sv-tests csvs identical to the law sweep's, surelog differing only in the
two LowMem log paths; byteverify verified vs law and verified vs control 0
movers in all three stages with the self-checks flagging 961, 1607 and 804;
the 4087 probe databases dump-identical to the control; the 48 sv-tests
databases the runner keeps STRICT_EQUAL against the law sweep's (tnoc by the
raw walk, `--no-canon`, since its canonical walk overflows; uhdm-cmp 0 lines);
canaries ok=52 and ok=16, ctcan2 PASS on both; audit 1523 of 1573, 1740 of
1740, 2346 of 2346 naming the verified binary; trace directory empty, as
predicted.

The corpus stages exited 0 on both sweeps (tests/LAWS.md regenerated with
this README's cases before the law sweep).

## Residues (ranked; all wrong on pristine too, none moved away from pristine)

1. The implementer's list stands: PF/pf17 (a typedef'd unpacked array),
   pf20 / pf33 / IF/if11 / if12 (a loop variable named like a declaration),
   PV/pv04 (an ANSI input port; here also VP/vp05 output and vp06 non-ANSI,
   byte-identical), PV/pv03 (2-D packed), PF/pf08 (two program instances; the
   same fullname face on VA/va08 and va12, a program under a generate block
   and a program in a module instantiated twice), PF/pf04 / VB/vb05 (a
   process-local array: the reads now bind the int_var where golden binds an
   array_var it lists as a program variable).
2. The refinement's two cases (VA/va27, VS/vs16), where this exporter's
   program listing disagrees with golden's (below).
3. Struct-net members where this exporter's listing is still an array_var and
   golden's an array_net (VS/vs07 dynamic, vs08 unpacked struct, vs13 queue,
   vs14 associative, vs23 nested struct): the loop variable is now right and
   the listing is the next face.
4. A same-name nested foreach (VA/va16): the inner loop abstains on the
   shadow walk and its read still binds an implicit net, where golden binds
   the outer array_var.
5. Interfaces: a parameterized width's range (VI/vi02), struct and net arrays
   (vi06, vi13 to vi15, vi18) closer but at the listing or range faces; an
   interface task body (vi12) not reached.
6. Class-method foreach in a program (VA/va25, va26): not reached.
7. The carried backlog of passes 441 and earlier, untouched.

## Sister-ground faces (reported, not written)

- ModuleEmit's program variable/net listing: this exporter lists an unpacked
  union array (VS/vs16) and an array of a typedef'd struct array (VA/va27) as
  an array_net where golden lists an array_var, and a dynamic, queue,
  associative, unpacked or nested logic-struct array (VS/vs07, vs08, vs13,
  vs14, vs23) as an array_var where golden lists an array_net; Surelog's rule
  is NetlistElaboration's elabSignal (a struct whose every leaf is a logic or
  reg vector, a net or reg vector array -> net). Once that listing follows
  golden, the listedNet branch of § progStructNetElemKeeps443v covers the rest
  by itself.
- The implementer's: UhdmExporter's pendingForeachArrayTs drain (PF/pf17),
  ModuleEmit's program listing of a process-local variable (PF/pf04), the
  never-instantiated definition admission of three basejump rows.

## Process

The VERIFIER stayed within the budget: one law build (equal to the
implementer's), one verified build, one five-stage sweep on each, no
pristine build and no pristine sweep (the master's control and the
implementer's frozen base build). The refinement was decoded and built
before any sweep ran. Slips, none affecting a measurement: the attack grids
ran while the sister r11u444's build was compiling (case runs only, no sweep
live); a first census trace column read 0 because its trace directories
were not created in advance (only the byte and exit-code columns are used,
the trace positive control coming from the per-case traced runs of
evidence/v11u443_attack_firings_ver.txt); the census and the downstream grid
ran after both sweeps had ended. The fence list was read into a file by a
program and never printed; every tree-wide path list was filtered on it
before any file was opened; no fenced test was named, opened or run; no other
agent's process was touched.

## Files

- cases/VA, VB, VI, VP, VS: 131 case dirs, each dut.sv naming its law in its
  first line (§ progStructNetElemKeeps443v on the 19 where the refinement
  fires).
- drivers/: grid.sh, classify.py, census.sh, judge.sh, dsgrid.py,
  probedump.sh, audit.py, fullsweep.sh, env.sh.
- evidence/: the attack and implementer grids on every binary and switch, the
  classifications, the firings, the census, the downstream tables, byteverify,
  the probe-dump summary, the sweep summaries and the prediction.
