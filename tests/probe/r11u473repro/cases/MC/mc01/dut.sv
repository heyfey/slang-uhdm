// § modImpCopyTdChainHomeTop473
// a module imports b, whose own parameter is typed by a's typedef
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
