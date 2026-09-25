// § crossPkgFoldTsNameOnChain152
package pk;
  localparam int unsigned N = 2;
  localparam int unsigned MSB = 4;
  localparam logic [MSB:0] R[N] = '{5'h1, 5'h11};
endpackage
module top(output logic [4:0] o);
  import pk::*;
  assign o = R[1];
endmodule
