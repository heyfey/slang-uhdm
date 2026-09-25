// § crossPkgFoldTsNameOnChain152
package pk;
  localparam int unsigned MSB = 3;
  localparam logic [MSB:0] R[2] = '{4'h1, 4'h2};
  localparam logic [MSB-1:0] S[2] = '{3'h1, 3'h2};
endpackage
module top(output logic [3:0] o);
  assign o = 4'd0;
endmodule
