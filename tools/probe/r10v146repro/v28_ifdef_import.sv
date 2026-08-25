// The $unit import lives behind an `ifdef, and a second package is imported
// in the dead branch.
`define USE_A
package pv28a;
  parameter int AF = 71;
endpackage
package pv28b;
  parameter int BF = 72;
endpackage
`ifdef USE_A
import pv28a::*;
`else
import pv28b::*;
`endif
module top_v28;
  int z;
  initial z = AF;
endmodule
