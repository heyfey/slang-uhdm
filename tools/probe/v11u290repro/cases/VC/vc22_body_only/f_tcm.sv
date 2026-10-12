// § elabOvSpliceTopCopy290
`include "hdr.svh"
module tcm #(parameter TCM_SIZE = 32'h00010000)(
  input logic clk,
  input logic [31:0] imem_addr,
  output logic [31:0] q);
dpm #(.SIZE(TCM_SIZE)) i_dp (.clk(clk), .addra(imem_addr[15:2]), .qa(q));
endmodule
