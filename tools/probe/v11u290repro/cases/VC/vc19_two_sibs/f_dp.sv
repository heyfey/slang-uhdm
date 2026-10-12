// § misevalShareOperandOnly290v
module dpm #(parameter SIZE = 32'h00010000)(
  input logic clk,
  input logic [$clog2(SIZE)-1:2] addra,
  output logic [31:0] qa);
localparam int unsigned AW = $clog2(SIZE);
localparam int unsigned RW = SIZE/4;
logic [31:0] ram_block [RW-1:0];
logic [AW-1:0] x;
always_ff @(posedge clk) qa <= ram_block[addra[3:2]] ^ x;
endmodule
