// v98_c8 — a PARAMETERIZED base with THREE live specialisations; the reference
// in each derived specialisation.  Determinism of specializations() too.
package p8v;
  class a8win98v; typedef bit [4:0] pk8_t; endclass
  class b8base98v #(int W = 1);
    typedef int pk8_t;
    function void own(pk8_t x); endfunction
  endclass
  class c8der98v #(int W = 1) extends b8base98v#(W);
    function void hot(pk8_t x); endfunction
    typedef pk8_t local8_t;
  endclass
endpackage
module top8v;
  import p8v::*;
  c8der98v#(1) a; c8der98v#(2) b; c8der98v#(3) c;
  initial begin a = new(); b = new(); c = new(); end
endmodule
