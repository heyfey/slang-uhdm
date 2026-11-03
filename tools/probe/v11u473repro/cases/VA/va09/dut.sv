// § modImpCopyTdChainHomeTop473
// module also imports a, own parameter typed t
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import a::*;
  import b::*;
  parameter t MP = PB;
  assign y = MP;
endmodule
