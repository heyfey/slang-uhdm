// § modImpCopyTdChainHomeTop473
// a bit-vector typedef and two parameters
package a;
  typedef bit [7:0] t;
endpackage
package b;
  import a::*;
  parameter t P1 = 8'h11;
  localparam t P2 = P1 + 1;
endpackage
module top(output logic [7:0] y);
  import b::*;
  assign y = P2;
endmodule
