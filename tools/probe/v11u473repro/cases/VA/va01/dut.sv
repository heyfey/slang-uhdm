// § modImpCopyTdChainHomeTop473
// generate block reads PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  if (1) begin : g
    assign y = PB;
  end
endmodule
