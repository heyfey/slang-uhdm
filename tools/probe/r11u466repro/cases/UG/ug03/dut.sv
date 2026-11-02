// § unitGroupKeepsHomeOrder466
package h;
  class K;
    extern function int f1();
    extern function int f2();
  endclass
`define DEFK(N, V) function int K::N(); return V; endfunction
  `DEFK(f1, 1)
  function int K::f2(); return 2; endfunction
endpackage
import h::*;
module top(input logic clk, output logic o);
  assign o = clk;
endmodule
