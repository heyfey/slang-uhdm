// r10uvm61 VERIFIER ARM v3_nonsub — the contexts where `currentSubSym` is NOT
// the enclosing subroutine.  The predicate's FIRST clause is
// `if (!currentSubSym) return false;` and its home is
// `currentSubSym->getParentScope()`.  `currentSubSym` is set/restored only
// around a subroutine BODY emit (src/TaskFuncEmit.cpp:5072/5260), so every
// class-scoped expression emitted OUTSIDE a body is an untested cell: either
// the predicate is off (under-fire) or -- the real danger -- some emission
// path reaches these while a sibling method's `currentSubSym` is still live,
// which would fold in a context golden may not.
package v3_pkg;

  class init_c;
    logic [4:0] m_a;
    // R1: a class PROPERTY INITIALISER querying an earlier own property.
    // Declared AFTER a method so that, if `currentSubSym` leaked, it would be
    // the method's.
    function int f_first();
      return $bits(m_a);          // control: must fold
    endfunction
    int m_init = $bits(m_a);      // R1
  endclass

  class cons_c;
    rand logic [5:0] m_r;
    logic [5:0]      m_w;
    // R2: a CONSTRAINT block -- not a subroutine at all
    constraint c_r { m_r < $bits(m_w); }
    function int f_ctl();
      return $bits(m_w);          // control
    endfunction
  endclass

  class dflt_c;
    logic [6:0] m_d;
    // R3: a method's DEFAULT ARGUMENT VALUE.  Compiled in class scope; the
    // argument list is emitted before/around the body.
    function int f_d(int x = $bits(m_d));
      return x + $bits(m_d);      // control on the same line pair
    endfunction
  endclass

  class dim_c;
    logic [3:0] m_v;
    // R4: an own property whose UNPACKED DIMENSION reads $bits of another own
    // property -- a declaration-bound $bits inside a class.
    logic        m_arr[$bits(m_v)];
    // R5: a class LOCALPARAM initialised from $bits of an own property
    localparam int LPB = $bits(m_v);
    function int f_dim();
      return $bits(m_v);          // control
    endfunction
  endclass

  // R6: a class method that is never CALLED anywhere (definition-only emit)
  class uncalled_c;
    logic [7:0] m_u;
    function int f_u();
      return $bits(m_u);
    endfunction
  endclass

endpackage

module v3_top;
  import v3_pkg::*;
  int o;
  initial begin
    init_c a = new(); cons_c b = new(); dflt_c c = new(); dim_c d = new();
    o = a.f_first(); o = a.m_init;
    o = b.f_ctl();
    o = c.f_d();
    o = d.f_dim();
  end
endmodule
