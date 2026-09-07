// r10v194 arm D — THE SCOPE SHAPES.  § homeRetNameSelBindSurvivesDefViewUnbind194
// keeps a binding whose PRODUCER (`noteSelectObj` + `endSelTrack`) models
// Surelog's `uhdmbegin` arm — "the select is a DIRECT statement of a block on
// the reference's own scope chain".  Every shape below is a place where the two
// scope models could disagree, and a disagreement in the WE-BIND direction is a
// pristine-RIGHT -> patched-WRONG regression that no other arm would show.
// All cells are OUT-OF-BODY class methods, where the exemption is live.
//
//   d_for      the select is the body of a `for` WITHOUT begin/end
//   d_forbeg   the select is a statement of a `for` body's own begin/end
//   d_while    the select is the body of a `while` WITHOUT begin/end
//   d_case     the select is a `case` arm WITHOUT begin/end (the `if`-arm shape)
//   d_casebeg  the select is a statement of a `case` arm's begin/end
//   d_blk     the select is a statement of a `fork ... join` arm
//   d_rval     the return name is only ever SELECTED AS AN RVALUE (never an
//              assignment Lhs), so Surelog's `Lhs()->VpiName() == name` test
//              can never answer and neither may we
package vd194_src;
  class VD194;
    extern function string d_for();
    extern function string d_forbeg();
    extern function string d_while();
    extern function string d_case();
    extern function string d_casebeg();
    extern function string d_blk();
    extern function string d_rval();
  endclass

  function string VD194::d_for();
    int i;
    d_for = {d_for,"   "};
    for (i = 0; i < 3; i++)
      d_for[i] = 8'h41;
  endfunction

  function string VD194::d_forbeg();
    int i;
    d_forbeg = {d_forbeg,"   "};
    for (i = 0; i < 3; i++) begin
      d_forbeg[i] = 8'h42;
    end
  endfunction

  function string VD194::d_while();
    int i;
    d_while = {d_while,"   "};
    i = 0;
    while (i < 3)
      d_while[i] = 8'h43;
  endfunction

  function string VD194::d_case();
    int i;
    d_case = {d_case,"   "};
    i = 0;
    case (i)
      0: d_case[i] = 8'h44;
      default: i = 1;
    endcase
  endfunction

  function string VD194::d_casebeg();
    int i;
    d_casebeg = {d_casebeg,"   "};
    i = 0;
    case (i)
      0: begin
        d_casebeg[i] = 8'h45;
      end
      default: i = 1;
    endcase
  endfunction

  // A named begin/end nested DIRECTLY inside the body block: the select is a
  // direct statement of the INNER block and the whole refs sit in the OUTER
  // one, the reverse of arm B's `b_nest` only in that the inner block is
  // ANONYMOUS here.
  function string VD194::d_blk();
    int i;
    d_blk = {d_blk,"   "};
    i = 0;
    begin
      d_blk[i] = 8'h46;
    end
  endfunction

  // The return name is written WHOLE and read through an RVALUE select only.
  function string VD194::d_rval();
    int i; byte b;
    i = 0;
    d_rval = {d_rval,"   "};
    b = d_rval[i];
    d_rval = {d_rval, string'(b)};
  endfunction
endpackage

module vd194_top;
  import vd194_src::*;
  VD194 h;
  string s1, s2, s3, s4, s5, s6, s7;
  initial begin
    h = new();
    s1 = h.d_for();
    s2 = h.d_forbeg();
    s3 = h.d_while();
    s4 = h.d_case();
    s5 = h.d_casebeg();
    s6 = h.d_blk();
    s7 = h.d_rval();
  end
endmodule
