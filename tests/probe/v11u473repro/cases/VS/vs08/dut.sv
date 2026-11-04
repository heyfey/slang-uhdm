// § modImpCopyTdChainHomeTop473
// two modules importing b, both top-level
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module m1(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
module m2(output logic [3:0] y);
  import b::*;
  assign y = ~PB;
endmodule
