// § elabOvMisevalRestampFile290
module dpm #(parameter SIZE = 32'h00010000, parameter NB = 4)(
  input logic clk,
  input logic [$clog2(SIZE)-1:2] addra,
  input logic [$clog2(SIZE)-1:2] addrb,
  output logic [31:0] qa);
localparam int unsigned RAM_SIZE_WORDS = SIZE/NB;
logic [31:0] ram_block [RAM_SIZE_WORDS-1:0];
always_ff @(posedge clk) qa <= ram_block[addra];
endmodule
