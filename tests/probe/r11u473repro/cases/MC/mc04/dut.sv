// § modImpCopyTdChainHomeTop473
// a localparam of the imported typedef, read in a module process
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  localparam t LB = 4'd7;
endpackage
module top(output logic [3:0] y);
  import b::*;
  always_comb y = LB;
endmodule
