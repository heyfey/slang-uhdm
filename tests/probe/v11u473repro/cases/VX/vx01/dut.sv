// § modImpCopyTdChainHomeTop473
// one instance of a child reading PB + 1
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
module top(output logic [3:0] y1);
  sub u1(y1);

endmodule
