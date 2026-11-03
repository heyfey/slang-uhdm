// § modImpCopyTdChainHomeTop473
// b imports the typedef explicitly
package a;
  typedef logic [5:0] t;
endpackage
package b;
  import a::t;
  parameter t PB = 6'd9;
endpackage
module top(output logic [5:0] y);
  import b::*;
  assign y = PB;
endmodule
