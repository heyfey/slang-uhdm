// § ovCloneChainSiblingOperand290v
parameter P_LOCAL = 1'b1;
`include "hdr.svh"
module top(input logic clk, input logic [31:0] a, output logic [31:0] q);
tcm #(.TCM_SIZE(32'(~P_MASK + 1'b1))) i_tcm (.clk(clk), .imem_addr(a), .q(q));
first_claim u();
endmodule
