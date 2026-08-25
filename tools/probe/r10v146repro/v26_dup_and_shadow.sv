// The same package imported twice at $unit AND a module localparam shadowing it.
package pv26;
  parameter int TWO = 26;
endpackage
import pv26::*;
import pv26::*;
module top_v26;
  localparam int TWO = 2;
  int z;
  function automatic int f(); return TWO; endfunction
  initial z = f() + TWO;
endmodule
