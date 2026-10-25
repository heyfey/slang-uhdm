// § modArrConcatInitElemSize430
module top(input logic clk, output logic [7:0] o);
  logic [7:0] rom [0:1] = {8'h3C, 8'hA5};
  logic idx = 0;
  always_ff @(posedge clk) begin idx <= ~idx; o <= rom[idx]; end
endmodule
