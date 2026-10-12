// § ovCloneChainSiblingOperand290v
module dpm #(parameter SIZE = 32'h00010000)(
  input logic clk,
  input logic [13:0] addra,
  output logic [31:0] qa);
logic [31:0] ram_block [3:0];
always_ff @(posedge clk) qa <= ram_block[addra[1:0]];
endmodule
