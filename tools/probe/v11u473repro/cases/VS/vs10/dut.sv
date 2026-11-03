// § modImpCopyTdChainHomeTop473
// nested instance under generate
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
  logic [3:0] w = PB;
  assign y = w;
endmodule
module top(output logic [3:0] y);
  if (1) begin : g
    sub u(y);
  end
endmodule
