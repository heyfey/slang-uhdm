module leaf #(parameter int AW = 16)(input logic clk);
  logic [AW-1:0] a;
endmodule
module recv #(parameter int AW = 5)(input logic clk);
  leaf larr[3](.clk(clk));
endmodule
module top;
  logic clk;
  recv #(.AW(7)) u (.clk(clk));
endmodule
