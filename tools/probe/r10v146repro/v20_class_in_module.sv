// A CLASS inside a module whose method reads a module localparam shadowing
// the $unit import.
package pv20;
  parameter int LEN = 70;
endpackage
import pv20::*;
module top_v20;
  localparam int LEN = 7;
  class c20;
    function int m(); return LEN; endfunction
  endclass
  int z;
  initial z = LEN;
endmodule
