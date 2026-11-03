// § modImpCopyTdChainHomeTop473
// module imports b and a, reads only PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  import a::*;
  assign y = PB;
endmodule
