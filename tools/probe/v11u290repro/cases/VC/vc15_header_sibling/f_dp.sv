// § elabOvMisevalCloneChain290
module dpm #(parameter SIZE = 32'h00010000, parameter RW = SIZE/4)(
  input logic clk,
  input logic [$clog2(SIZE)-1:2] addra,
  output logic [31:0] qa);
logic [31:0] ram_block [3:0];
always_ff @(posedge clk) qa <= ram_block[addra[3:2]];
endmodule
