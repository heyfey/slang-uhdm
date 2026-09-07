// r10v186 (VERIFIER) ARM A — THE RETURN-NAME AND FORMAL-DIRECTION AXIS of a
// dynamic-array `new[...]` argument in a WILDCARD-IMPORT CLONE.
//
// § cloneNewArrayArgBindsOwnDecl186 lifts § newArrayArgNoBind16's silence for
// EVERY symbol `newArraySubScopeSym16` answers TRUE for, and that predicate
// walks a chain and accepts any Variable / FormalArgument / Iterator whose
// home is a package.  A FUNCTION'S OWN RETURN NAME is a Variable whose parent
// scope is the Subroutine, so it is inside the lifted window — and
// § retNameArgKeepsReturnVar184v is the standing law that a FREE subroutine's
// return-name argument keeps § 171's RETURN VARIABLE and must not be reclaimed
// by a clone law.  This arm asks one real Surelog golden what the clone's
// answer is for that face and for every formal DIRECTION (input / output /
// inout / ref / const ref), which the corpus never exercises: the corpus'
// `io_decl (addr)` cell is an `input`.
//
// Names, numbers and orders deliberately unlike the corpus' and unlike
// r10uvm186's own arms.
package Trellis186v;

  int fringe186v = 9;

  // R1 the RETURN NAME as the size argument of a free function's `new[...]`.
  function automatic int quoin186v(input int in_a, output int out_b,
                                   inout int io_c, ref int rf_d);
    int    dyn186v[];
    int    body186v;
    body186v = in_a + 1;
    out_b   = in_a + 2;
    io_c    = io_c + 3;
    quoin186v = in_a + 4;            // the return name is assigned first
    dyn186v = new[quoin186v];        // R1  the RETURN NAME
    dyn186v = new[in_a];             // R2  an INPUT formal   (the corpus face)
    dyn186v = new[out_b];            // R3  an OUTPUT formal
    dyn186v = new[io_c];             // R4  an INOUT formal
    dyn186v = new[rf_d];             // R5  a REF formal
    dyn186v = new[body186v];         // R6  a body local      (the corpus face)
    dyn186v = new[fringe186v];       // R7  a PACKAGE variable (the FENCE)
    return dyn186v.size();
  endfunction

  // R8 a STATIC free function — the return name in the static flavour.
  function int lintel186v(input int in_e);
    int dyn186v[];
    lintel186v = in_e + 5;
    dyn186v = new[lintel186v];       // R8  RETURN NAME, static function
    return dyn186v.size();
  endfunction

  // R9 the return name of a function that never assigns it before the `new`.
  function automatic int soffit186v(input int in_f);
    int dyn186v[];
    dyn186v = new[soffit186v];       // R9  RETURN NAME, never assigned
    soffit186v = in_f + dyn186v.size();
    return soffit186v;
  endfunction

  class Newelpost186v;
    int m_bracket;
    int m_bag[];
    extern function int sill186v(input int in_g);
    function int jamb186v(input int in_h);   // IN BODY — never cloned
      int dyn186v[];
      dyn186v = new[in_h];
      jamb186v = dyn186v.size();
      m_bag = new[jamb186v];                 // R10 in-body return name
      return jamb186v + m_bag.size();
    endfunction
  endclass

  // R11 an OUT-OF-BODY class method's return name.
  function int Newelpost186v::sill186v(input int in_g);
    int dyn186v[];
    sill186v = in_g + 6;
    dyn186v = new[sill186v];         // R11 RETURN NAME, out-of-body method
    m_bag  = new[m_bracket];         // R12 CLASS PROPERTY (the FENCE)
    return dyn186v.size() + sill186v;
  endfunction

  // R13 a TASK's output / ref formals — a task has no return name.
  task automatic dowel186v(input int in_i, output int out_j, ref int rf_k);
    int dyn186v[];
    out_j = in_i + 7;
    dyn186v = new[out_j];            // R13 a TASK's OUTPUT formal
    dyn186v = new[rf_k];             // R14 a TASK's REF formal
    out_j = dyn186v.size();
  endtask

endpackage

// The WILDCARD clone — the listing the law owns.
package Wainscot186v;
  import Trellis186v::*;
  int carry186v = 13;
  function automatic int use_wainscot186v();
    int a1, b1, c1, d1;
    int out186v;
    Newelpost186v peg186v;
    a1 = 1; b1 = 0; c1 = 2; d1 = 3;
    peg186v = new();
    out186v = quoin186v(a1, b1, c1, d1) + lintel186v(4) + soffit186v(5);
    out186v = out186v + peg186v.sill186v(6) + peg186v.jamb186v(7);
    return out186v;
  endfunction
  task automatic use_wainscot_t186v(output int res186v);
    int r1, r2;
    r1 = 0; r2 = 8;
    dowel186v(2, r1, r2);
    res186v = r1 + r2;
  endtask
endpackage

module top186va;
  import Wainscot186v::*;
  int tally186v;
  int tick186v;
  initial begin
    use_wainscot_t186v(tick186v);
    tally186v = use_wainscot186v() + tick186v;
    $display("%0d", tally186v);
  end
endmodule
