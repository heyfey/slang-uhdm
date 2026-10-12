// § ovCloneChainSiblingOperand290v
`include "hdr.svh"
module tcm #(parameter TCM_SIZE = 32'h00010000)(
  input logic clk,
  input logic [31:0] imem_addr,
  output logic [31:0] q);
localparam AW = $clog2(TCM_SIZE);
dpm #(.SIZE(TCM_SIZE)) i_dp (.clk(clk), .addra(imem_addr[AW-1:2]), .qa(q));
endmodule
