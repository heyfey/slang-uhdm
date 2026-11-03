// § modImpCopyTdChainHomeTop473
// three levels: c imports b, b imports a, module imports c
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
package c;
  import b::*;
  export b::*;
  parameter int PC = PB + 0;
endpackage
module top(output logic [3:0] y);
  import c::*;
  assign y = PB + PC;
endmodule
