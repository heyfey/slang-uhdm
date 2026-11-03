// § modImpCopyTdChainHomeTop473
// localparam in b
package a;
  typedef logic [7:0] t;
endpackage
package b;
  import a::*;
  localparam t LB = 8'h3c;
endpackage
module top(output logic [7:0] y);
  import b::*;
  logic [7:0] w = LB;
  assign y = w & LB;
endmodule
