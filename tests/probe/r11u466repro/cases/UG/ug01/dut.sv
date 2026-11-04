// § unitGroupKeepsHomeOrder466
package h;
  class K;
    extern function int f1();
    extern function int f2();
    extern function int f3();
    extern function int f4();
  endclass
  function int K::f1(); return 1; endfunction
`define DEFK(N, V) function int K::N(); return V; endfunction
  `DEFK(f2, 2)
  function int K::f3(); return 3; endfunction
  `DEFK(f4, 4)
  function int hf(); return 5; endfunction
endpackage
package g;
  import h::*;
  typedef logic [3:0] g_t;
endpackage
import g::*;
module top(input logic clk, output logic o);
  assign o = clk;
endmodule
