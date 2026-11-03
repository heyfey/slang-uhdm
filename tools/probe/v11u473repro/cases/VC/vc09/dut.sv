// § modImpCopyTdChainHomeTop473
// a third package d also imports a and lists t
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
package d;
  import a::*;
  parameter t PD = 7;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
