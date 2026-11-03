// § modImpCopyTdChainHomeTop473
// two modules import b, one instantiates the other
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub(output logic [3:0] o);
  import b::*;
  assign o = PB;
endmodule
module top(output logic [3:0] y);
  import b::*;
  sub u(.o(y));
endmodule
