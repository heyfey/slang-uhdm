// A PARAMETERIZED CLASS whose own parameter shadows the $unit import.
package pv22;
  parameter int NN = 90;
endpackage
import pv22::*;
package pv22b;
  class c22 #(int NN = 9);
    function int m(); return NN; endfunction
  endclass
endpackage
module top_v22;
  int z;
  initial z = NN;
endmodule
