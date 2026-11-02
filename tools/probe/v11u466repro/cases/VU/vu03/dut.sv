// § unitGroupKeepsHomeOrder466
package h;
  class K;
    extern function int f1();
    extern function int f2();
  endclass
`define DEFK(N, V) function int K::N(); return V; endfunction
  function int K::f2(); return 2; endfunction
  `DEFK(f1, 1)
endpackage
import h::*;
module top(input logic clk, output logic o);
  import h::*;
  assign o = clk;
endmodule
