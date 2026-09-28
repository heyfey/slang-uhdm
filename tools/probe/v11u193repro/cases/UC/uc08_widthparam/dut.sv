// § ucCloneUnnamesRanges193v
module m #(parameter int W = 4) (input logic c, input logic x, output logic [7:0] y);
  assign y[W-1:0] = c ? {W{x}} : '0;
endmodule
module top (input logic c, input logic x, output logic [7:0] y1, output logic [7:0] y2);
  m #(.W(4)) u_a (.c(c), .x(x), .y(y1));
  m #(.W(8)) u_b (.c(c), .x(x), .y(y2));
endmodule
