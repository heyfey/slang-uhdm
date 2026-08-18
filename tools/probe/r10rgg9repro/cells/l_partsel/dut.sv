module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign vec[3:0] = (P) ? {4{sig}} : '0;

endmodule
module top;
  m #(.P(0)) u_a();
endmodule
