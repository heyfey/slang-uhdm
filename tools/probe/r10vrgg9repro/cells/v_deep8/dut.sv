module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? (P) ? 42 : 0 : 1 : 2 : 3 : 4 : 5 : 6 : 7;

endmodule
module top;
  m #(.P(1)) u_a();
endmodule
