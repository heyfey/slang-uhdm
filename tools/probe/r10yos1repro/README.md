# r10yos1 — § dottedTopNameBareElab

**Target:** `YosysVerx` (surelog corpus), `CMP_NOTEQUAL` on **both** modes.

## The one rung

`tools/probe/r10ladder1repro/ladder_{default,testflags}_YosysVerx.txt` both show
exactly ONE rung and then `stop=FIXPOINT`:

```
RUNG 1 KINDL=<null> KINDR=module_inst KINDP=design SHAPE=EXTRA-OURS
   R  module_inst(work@vexriscv.demo.GenFull)@vexriscv.demo.GenFull.v:1059:1-7202:10
```

`uhdm-cmp` agrees — one head, `LHS: <null>`, RHS = our whole elaborated top.
Object counts: golden 24,205, ours 36,089.

The design carries three modules (`InstructionCache`, `DataCache`, and the
escaped-name `\vexriscv.demo.GenFull`, which instantiates the other two), so
there is exactly ONE top and both tools agree on which. This is **not** a
top-SELECTION difference — the def views are already byte-identical:

```
head -127961 golden.dump  vs  head -127961 ours.dump   ->  identical
```

(only the filename banner differs). The entire divergence is the
`uhdmtopModules` entry.

## The law

**§ dottedTopNameBareElab** — a design top whose module NAME contains a `.`
(reachable only through an escaped identifier, `module \a.b.C ... endmodule`)
is **not elaborated** by Surelog. Its `uhdmtopModules` entry is a BARE
`module_inst`:

```
\_module_inst: work@a.b.C (work@a.b.C), file:..., line:1059:1, endln:7202:10
  |vpiParent:  \_design: (work@a.b.C)
  |vpiName:work@a.b.C
  |vpiDefName:work@a.b.C
  |vpiTop:1
  |vpiTopModule:1
```

and nothing else: no nets, ports, cont_assigns, parameters, processes or child
instances. Surelog's own log says so independently —
`Nb instances: 1 / Max instance depth: 1 / Nb leaf instances: 1` even though
the module instantiates two children. The DEF view (`uhdmallModules`) is
completely unaffected. Mechanism: Surelog builds elaborated instance paths by
concatenating with `.`, so a dotted top name makes the top instance's own
hierarchical path unresolvable and the instance tree comes back empty.

## The grid — `./grid.sh`

Ten purpose-built arms, each a real Surelog run:

| arm | top name | Nb instances | topModules entry |
|---|---|---|---|
| `a_simple` | `top` | 2 | FULL-ELAB |
| `b_escaped` | `\a.b.C` | 1 | **BARE-SHELL** |
| `c_multitop` | `top1`, `top2` | 4 | FULL-ELAB, FULL-ELAB |
| `d_escnodot` | `\foo` | 2 | FULL-ELAB |
| `e_escdot_nochild` | `\a.b.C` (no child inst) | 1 | **BARE-SHELL** |
| `f_escbracket` | `\a[0]` | 2 | FULL-ELAB |
| `g_escdollar` | `\a$b` | 2 | FULL-ELAB |
| `h_dotchild` | `top` (dotted CHILD) | 2 | FULL-ELAB |
| `i_multitop_onedot` | `\a.b.C` + `plaintop` | 3 | **BARE-SHELL** + FULL-ELAB |
| `j_plainfirst_dotsecond` | `plaintop` + `\a.b.C` | 3 | FULL-ELAB + **BARE-SHELL** |

What each boundary buys:

* `d/f/g` — escaping is NOT the discriminator. `\foo`, `\a[0]` and `\a$b` all
  elaborate normally. It is the **dot**.
* `h_dotchild` — the dot must be in the **TOP's own** name; a dotted name on a
  child module elaborates normally.
* `e_escdot_nochild` — a dotted top with NO child instance is STILL bare, so
  this is the top instance itself failing, not a child walk.
* `i`/`j` — the rule is **per top**, not per design: the plain top beside a
  dotted one elaborates fully, in both orders. Design naming and top ORDER are
  unaffected (source order, as always).

## The census — `./census.sh`

Both corpora, every escaped module/interface/program/primitive declaration,
split on "does the declared NAME contain a dot":

```
surelog:    escaped-name declarations = 101  (dotted = 1, plain = 100)
uhdm2rtlil: escaped-name declarations =   2  (dotted = 0, plain = 2)
```

The single dotted name in either corpus is
`third_party/tests/YosysVerx/vexriscv.demo.GenFull.v: \vexriscv.demo.GenFull`,
and it is that test's top. **Predicted movers: YosysVerx default + testflags
and nothing else.** (The census deliberately cuts the declared name at the
first whitespace: `module \dut$interfaces$sim_sram_if (a, \ss_if.start_addr );`
has a dot in a PORT name and must not count. The uhdm2rtlil `*_from_*.v` /
`*_synth.v` files are Yosys OUTPUT and are never compiled by a test.)

## The change

`UhdmExporter::exportDesign` classifies a top as bare when its definition name
contains a `.`; `UhdmExporter::emitBareTopShell` (ModuleEmit.cpp) emits the
shell and nothing else. Every def under a bare top joins `unrefDefs`, so it
fills its port phase in the existing **write-phase fallback**, NAME-SORTED.

Two measurements shaped that, both worth keeping:

1. **The first cut filled those defs during the top loop** (walking the instance
   tree for its def-fill side effect alone, in the elaborated walk's
   first-encounter order). It converted the row — but left 77 def-view PORT
   typespecs in the wrong arena slot: ours `GenFull, InstructionCache,
   DataCache`, golden's name-sorted and interleaved with each def's local-net
   typespecs. Reason: a def-view port typespec belonging to a def that HAS an
   elaborated instance is not the object `emitModuleDefPorts` made — the write
   phase recompiles it (`drainElabPortTs` / the `emitTopPorts` swap) at the
   def's name-sorted slot, and that is the object that survives. With no
   elaboration at all, the only way to land in the same slot is to fill the def
   there. Fixing it turned `dump differ` into `dump match`.
2. **A `tfContext = true` for the bare top's own def-net drain was NOT shipped.**
   A bare top pushes no `TopPending`, so its def net typespecs drain on the
   non-top rule; the argument for forcing the top rule (Surelog compiled the
   module the same way regardless of elaboration) is plausible and *unmeasured*,
   so it was built behind a switch and run both ways. The two databases are
   **byte-identical** — the predicate is inert on the only witness that exists,
   so it is a comment, not code. It could only bite for a dotted top with
   param-dependent net ranges, and `census.sh` shows there is no such test.
