// § modImpCopyTdChainHomeTop473
// two instances of a child importing b
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub(output logic [3:0] y);
  import b::*;
  assign y = PB + 1;
endmodule
module top(output logic [3:0] y1, y2);
  sub u1(y1);
  sub u2(y2);
endmodule
