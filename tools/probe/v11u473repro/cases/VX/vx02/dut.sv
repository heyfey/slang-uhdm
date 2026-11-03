// § modImpCopyTdChainHomeTop473
// two instances of a child, whole right side PB
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
module top(output logic [3:0] y);
  sub u(y);
  sub u2();
endmodule
