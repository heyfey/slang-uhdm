module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (P) ? 42 : 7, arr[1] = (P) ? 9 : 3;

endmodule
module top;
  m #(.P(1)) u_a();
endmodule
