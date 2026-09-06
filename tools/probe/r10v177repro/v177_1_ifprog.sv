// r10v177 adversarial arm 1 — HOMES THE IMPLEMENTER NEVER COMPILED.
// § ownNamedAliasRetIsRefVar177's free-subroutine walk answers `InstanceBody`
// with `&ss == &owner` and NO view gate, and slang's InstanceBody covers
// INTERFACES and PROGRAMS as well as modules.  Its `ctx.cls` arm answers ANY
// class, including one declared inside a MODULE and one declared in `$unit`.
// None of those four homes appears in g177_a/b/c/d.  Names, order and case are
// deliberately unlike the implementer's arms (RESUME §9: a grid that names
// everything a_t/b_t/c_t over A/B/C is self-confirming).

typedef enum { UNIT_RED, UNIT_GRN } Palette;   // $unit direct enum typedef
typedef Palette PaletteRef;                    // $unit alias OF A NAME

interface Wire9;
  typedef enum { IF_LO, IF_HI } LevelBase;     // INTERFACE-local direct enum td
  typedef LevelBase LevelRef;                  // INTERFACE-local alias of a name
  typedef byte      TinyBase;
  typedef TinyBase  TinyRef;

  function LevelBase ifDirect(); return IF_LO; endfunction
  function LevelRef  ifVia();    return IF_HI; endfunction
  function TinyRef   ifTiny();   return 8'd3;  endfunction
  function PaletteRef ifUnitVia(); return UNIT_RED; endfunction
endinterface

program Runner9;
  typedef enum { PG_A, PG_B } StageBase;       // PROGRAM-local direct enum td
  typedef StageBase StageRef;                  // PROGRAM-local alias of a name

  function StageBase pgDirect(); return PG_A; endfunction
  function StageRef  pgVia();    return PG_B; endfunction
  initial $display(pgDirect(), pgVia());
endprogram

// A class declared inside a MODULE: `tdDeclCtx10` answers ctx.cls, so the
// predicate fires with no package and no InstanceBody test at all.
module Holder9;
  Wire9 w9();

  class InModCls;
    typedef enum { CM_X, CM_Y } CmBase;        // CLASS-scope direct enum td
    typedef CmBase CmRef;                      // CLASS-scope alias of a name
    function CmBase cmDirect(); return CM_X; endfunction
    function CmRef  cmVia();    return CM_Y; endfunction
  endclass

  typedef enum { MD_P, MD_Q } ModBase;         // MODULE-local direct enum td
  typedef ModBase ModRef;                      // MODULE-local alias of a name
  function ModBase mdDirect(); return MD_P; endfunction
  function ModRef  mdVia();    return MD_Q; endfunction

  InModCls c9 = new();
  initial $display(mdDirect(), mdVia(), c9.cmDirect(), c9.cmVia(),
                   w9.ifDirect(), w9.ifVia(), w9.ifTiny(), w9.ifUnitVia());
endmodule

// A class declared in `$unit` — the predicate's CompilationUnit exclusion sits
// in the FREE-subroutine loop only, so a $unit class's own alias reaches the
// `ctx.cls` arm unguarded.
class UnitCls9;
  typedef enum { UC_1, UC_2 } UcBase;
  typedef UcBase UcRef;
  function UcBase ucDirect(); return UC_1; endfunction
  function UcRef  ucVia();    return UC_2; endfunction
  function PaletteRef ucUnitVia(); return UNIT_GRN; endfunction
endclass

// A free $unit function returning a $unit alias — the implementer's `unit_fn`
// (arm D) re-measured here under a different name and a different order.
function PaletteRef topUnitVia(); return UNIT_GRN; endfunction
