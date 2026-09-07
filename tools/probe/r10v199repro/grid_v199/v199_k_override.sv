package vpk;
  parameter K_UHEX = 'hf0;
endpackage
import vpk::*;
module kchild #(parameter P = K_UHEX) (input logic clk);
  logic q;
  always_ff @(posedge clk) q <= 1'b0;
endmodule
module vk(input logic clk);
  kchild #(.P('hab)) u0(clk);
  kchild u1(clk);
endmodule
