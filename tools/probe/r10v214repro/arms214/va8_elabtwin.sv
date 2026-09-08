// v214 arm 8 — DEF vs ELAB, side by side, with a parameter whose two views
// carry DIFFERENT values: `NW8` is folded to a 64-bit constant in the def
// listing and a 32-bit one in the elaborated listing (the § r10fsv3 S3b shape).
// The def clone listing must take the DEF Rhs and the elaborated listing the
// ELAB one.
package pv8;
  parameter int unsigned NW8 = 4;
  parameter NB8 = NW8 * 8;
  parameter NC8 = NB8;
  function automatic int sink8(int a, int b); return a + b; endfunction
  class C8;
    extern function int rd8();
    extern function int rd8b();
  endclass
  function int C8::rd8();
    return sink8(NB8, NC8);
  endfunction
  function int C8::rd8b();
    logic [NB8-1:0] loc;
    loc = '0;
    return int'(loc) + NC8;
  endfunction
endpackage
module topv8;
  pv8::C8 c = new();
  int x;
  initial x = c.rd8();
endmodule
