// § modImpCopyTdChainHomeTop473
// the module imports b through $unit
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
import b::*;
module top(output logic [3:0] y);
  assign y = PB;
endmodule
