// § unitGroupKeepsHomeOrder466
package h;
  class K;
    extern function int f1();
    extern function int f2();
    extern function int f3();
  endclass
  function int K::f3(); return 3; endfunction
  function int K::f1(); return 1; endfunction
  function int K::f2(); return 2; endfunction
  function int hf(); return 9; endfunction
endpackage
package g;
  import h::*;
  function int gf(); return 7; endfunction
endpackage
package g2;
  import h::*;
  function int gf2(); return 8; endfunction
endpackage
import g::*;
import g2::*;
module top(input logic clk, output logic o);
  assign o = clk;
endmodule
