// Imported but NEVER referenced; plus a package with NO parameters at all.
package pv11a;
  parameter int NEVER = 3;
  parameter int ALSO  = 4;
endpackage
package pv11b;
  typedef logic [2:0] t3;
endpackage
import pv11a::*;
import pv11b::*;
module top_v11;
  t3 x;
  assign x = 3'b101;
endmodule
