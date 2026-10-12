// § ovSpliceTopOperandStaysHome290v
module dpm #(parameter SIZE = 32'h00010000)(
  input logic clk,
  input logic [$clog2(SIZE)-1:2] addra,
  input logic [SIZE/16384-1:0] b,
  output logic [31:0] qa);
logic [31:0] ram_block [3:0];
always_ff @(posedge clk) qa <= ram_block[addra[3:2]] ^ b;
endmodule
