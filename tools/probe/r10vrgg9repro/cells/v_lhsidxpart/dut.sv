module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign vec[0 +: 4] = (P) ? 4'hA : 4'h5;

endmodule
module top;
  m #(.P(1)) u_a();
endmodule
