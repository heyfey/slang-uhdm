# r10uvm104 — § macroPasteDotText104

## Result

Surelog's preprocessor replaces the **single character between two token-paste
operators** inside a `` `"…`" `` stringification with a literal `.`, for every
character: `-`, `_`, `:`, `/`, `,`, `*`, `+`, a space, a letter, a digit.  It is
not a dash rule and not a deletion — the character is *overwritten with a dot*.

uvm-1.2 writes its version string as

```
`define UVM_VERSION_STRING `"`UVM_NAME``-```UVM_MAJOR_REV``.```UVM_MINOR_REV```"
```

(`src/macros/uvm_version_defines.svh:94`; line 92 is the `ifdef UVM_FIX_REV` twin, which
uvm-1.2 does not take), so the C-preprocessor-correct value
— and slang's — is `UVM-1.2`, while golden carries `UVM.1.2`.  That constant,
`base/uvm_version.svh:31`'s `parameter string uvm_revision`, WAS the SeqDriver
head in both modes.

The head is cleared.  SeqDriver goes 64 → 60 cmp lines in both modes and the
mismatch moves on to the next depth.  194 string cells across seven database
rows go to golden, 0 away.

## Surelog producer

`SV3_1aPpTreeShapeListener::enterString`
(`../Surelog/src/SourceCompile/SV3_1aPpTreeShapeListener.cpp:966-969`, inside `enterString` at `:910`):

```cpp
if (stringContent.find('`') != std::string::npos) {
  std::string stringData = stringContent;
  stringData.erase(0, 1);
  stringData.erase(stringData.end() - 1, stringData.end());
  static const std::regex backtick_dot_re("``.``");
  static const std::regex backtick_dash_re("``-``");
  stringData = std::regex_replace(stringData, backtick_dot_re, ".");
  stringData = std::regex_replace(stringData, backtick_dash_re, "-");
  ...
  stringData = m_pp->evaluateMacroInstance(stringData, ...);
```

The first pattern is the STRING `"``.``"` handed to `std::regex`, so its `.` is
an **unescaped ECMAScript wildcard**: `` `` ``·X·`` `` `` matches for any single
X and is replaced by `.`.  The second, dash-preserving regex is **dead code** —
the wildcard pass has already eaten every `` ``-`` ``.  Both run BEFORE
`evaluateMacroInstance` expands the macros inside the string, so the text being
rewritten is the macro DEFINITION's characters.

How the definition text reaches that listener: `PreprocessFile::evaluateMacro_`
(`../Surelog/src/SourceCompile/PreprocessFile.cpp:860-861`) rewrites the body's `` `" ``
tokens to plain `"` and then (`../Surelog/src/SourceCompile/PreprocessFile.cpp:1029-1050`) re-preprocesses the assembled body,
where the whole `"…"` lexes as ONE `STRING` token — the pp lexer's `STRING` rule
(`../Surelog/grammar/SV3_1aPpLexer.g4:163`) accepts backticks inside a string — and
`enterString` fires on it.  A macro WITH ARGUMENTS has had its formals
substituted first (`../Surelog/src/SourceCompile/PreprocessFile.cpp:919-931` consumes the pastes that touch a
formal), which is why 1800.2's `` `"ARRAY_TYPE``(``VALUE_TYPE``)`" `` does NOT
move.

The lexer detail that decides the SHAPE: `TICK_TICK: '``'`
(`../Surelog/grammar/SV3_1aPpLexer.g4:346`) is two characters and `Macro_identifier: '`' [a-zA-Z_]…`
(`../Surelog/grammar/SV3_1aPpLexer.g4:160`) needs a letter after its backtick, so ` ``` ` lexes as TICK_TICK +
macro-reference.  `` X``-```Y `` is therefore paste + `-` + paste + reference,
the five-character window the regex matches, while `` X``-`Y `` (one backtick)
is not.

## Model

`UhdmExporter::surelogPasteDotString` (declared in `include/UhdmExporter.h`,
defined in `src/ExprEmit.cpp`), called from the macro-quoted arm of
`ExpressionKind::StringLiteral` in `emitExpr` and from the string-parameter
value in `src/ParamEmit.cpp`.

1. The literal's start must be a MACRO location; `getFullyOriginalLoc` walks it
   back to the `` `" `` in the macro definition, and the body is the source text
   up to the matching `` `" `` (the escaped form `` `\`" `` is stepped over as
   content).
2. Surelog's two `std::regex_replace` calls are replayed, in Surelog's order, on
   that body.  **If the body is unchanged the function returns `nullopt` and the
   string is byte-identical** — that is the gate: `` `"x`" ``,
   `` `"typ doesn't have expected size width`" ``, every no-paste and
   two-character-separator shape, every identifier paste outside a string.
2b. A macro that takes FORMAL ARGUMENTS bails outright (verifier r10v104):
   Surelog substitutes the formals, consuming the pastes that touch one,
   BEFORE `enterString`'s regex runs, so the definition text is not what the
   regex sees.  The alignment walk cannot detect that on its own -- when the
   actual argument text coincides with the formal's name the definition lines
   up byte-for-byte -- so the enclosing `` `define `` is read directly.  See
   `GRID.txt` arm 4 (CORRECTION) and `../r10v104repro/README.md`.
3. Otherwise the body is parsed into macro references / pastes / literal
   characters, and each literal is aligned to its position in slang's expanded
   value by a left-to-right walk that anchors each macro reference on the next
   literal run.  The same walk is run RIGHT-TO-LEFT and the two must agree on
   every position; that is what resolves `OVM-2.1.2` and `UVM-1.1d`, whose
   separators repeat.  Any mismatch bails to the pristine rendering.
4. The regex's match POSITIONS are recovered with `sregex_iterator` and the
   aligned characters are set to `.`.

One character in, one character out, so the LENGTH never changes and `vpiSize`
follows the text with no separate rule (golden's 56 = 7×8 was already ours).
`expr::Compare` reads `VpiDecompile` first, then `VpiSize`, then `Typespec`
(`../UHDM/build/generated/src/expr.cpp:90-100`), so the decompile is
the field that clears this head; the value is written to match anyway so the
parameter object and its `param_assign` Rhs cannot disagree.

## Cells

Five files in the UVM trees carry the shape, all of them version strings:
uvm-1.2 (`UVM-1.2`), uvm-1.1d (`UVM-1.1d`), ovm-2.1.2 (`OVM-2.1.2`),
svaunit and svaunit_cp (`SVAUNIT-3.2`).  uhdm2rtlil has **zero** occurrences of
`` ``X`` `` anywhere.  1800.2-2017-1.0 — BuildUVMPkg's golden — writes its
version as a plain literal (`base/uvm_version.svh:30`), so BuildUVMPkg has NO
cell and its census score is unchanged (TO-GOLDEN 0, AWAY 0).

Seven database rows move, all seven predicted BY NAME from the pristine
databases before the patch was built: `MiniAmiq`, `Scoreboard`, `SeqDriver`,
`SimpleUVM` in default and `MiniAmiq`, `SeqDriver`, `SimpleUVM` in testflags.
MiniAmiq also carries the svaunit cell (`SVAUNIT-3.2` → `SVAUNIT.3.2`).

## Acceptance

All five gates green; see `GATES.txt`.  No row converts — SeqDriver stays
`CMP_NOTEQUAL` — so `results/*.csv` is untouched.  `GRID.txt` has the seven-arm
golden grid (golden-vs-golden calibrated at 0 cells), `CENSUS.txt` the keyed
multiset census (TO-GOLDEN 194, AWAY 0), `BOUNDARY.txt` both halves of the wide
boundary and the decoding of its one non-law mover.

## Residues

* **R-args** (verifier r10v104) — a paste window inside an ARGUMENT-BEARING
  macro that touches no formal, `` `define TAG(x) `"pre``-``post_``x`" ``, IS
  dotted by golden (`pre.post_zz`) and is not modelled: the fence bails on the
  whole macro.  Unchanged from pristine; no corpus source has the shape.
* **R-esc** — a `` `\`" `` escaped quote inside a stringification: golden keeps
  the backslash (`q\"ABC.1\"z`), we drop it (`q"ABC-1"z`).  Pre-existing,
  independent of this law, and no corpus source uses the form.  The model bails
  there rather than half-fixing it.
* **R-assoc** — `buildUnpackedArrayTypedefTs` (`src/TypeEmit.cpp:10359`) reads
  an `AssociativeArrayType` through an unchecked
  `as<FixedSizeUnpackedArrayType>()`, so a `typedef T x[string];` gets a range
  bound derived from a POINTER.  Pre-existing, corpus-invisible, and it will
  re-report on every future boundary until the cast is guarded.  See
  `BOUNDARY.txt`.
* **Plain strings with a backtick** — `enterString` fires on ANY string
  containing a backtick, not only on stringifications: golden turns
  `"a``-``b"` into `a.b` and `"a`N``-``b"` into `aABC.b` (it expands the macro
  inside a plain literal too).  Measured on golden, deliberately NOT modelled:
  no corpus source has a plain string literal with a paste in it, and the
  macro-expansion half is a much wider change.
