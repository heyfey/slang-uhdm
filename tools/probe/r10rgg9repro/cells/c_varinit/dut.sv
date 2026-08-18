module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  logic [7:0] v0 = (P) ? 8'd3 : 8'd4;


endmodule
module top;
  m #(.P(0)) u_a();
endmodule
