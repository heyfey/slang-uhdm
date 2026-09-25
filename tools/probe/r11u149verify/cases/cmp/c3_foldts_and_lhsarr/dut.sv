// § foldedBoundTsRefUnstored144 + § impLhsCloneArrayTsOwnCopy140 (composition, the ibex PmpAddrRst shape)
package pk;
  parameter int unsigned MSB = 7;
  parameter logic [MSB:0] R[2] = '{8'h10, 8'h20};
endpackage
module dut import pk::*; #(parameter int W = 4) (input logic s, output logic [7:0] o, output logic [W-1:0] z);
  logic [W-1:0] v;
  assign v = '0;
  assign z = v;
  assign o = R[s];
endmodule
