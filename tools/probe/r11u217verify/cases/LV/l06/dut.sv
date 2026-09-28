// § tfItemLocalSpecAtName209 — r11u217 l06: the specialization local in a paren-less method of a class in ANOTHER package importing the generic, and a typedef of the specialization used as a local type
package gp;
  class g #(int N = 1);
    int v;
  endclass
endpackage
package p;
  import gp::*;
  typedef g#(4) g4_t;
  class c;
    extern function void f;
  endclass
  function void c::f;
    g#(2) a = new;
    g4_t b = new;
    a.v = b.v;
  endfunction
endpackage
module top;
  p::c h;
endmodule
