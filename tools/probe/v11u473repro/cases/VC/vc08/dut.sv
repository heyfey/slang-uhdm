// § modImpCopyTdChainHomeTop473
// typedef homed in z, re-exported by a, used by b's parameter
package z;
  typedef logic [3:0] t;
endpackage
package a;
  import z::*;
  export z::*;
  parameter t PZ = 1;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
