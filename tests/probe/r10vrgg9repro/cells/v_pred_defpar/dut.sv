module m #(
  parameter bit P = 1
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (P) ? 42 : 7;

endmodule
module top;
  m u_a();
  defparam u_a.P = 0;
endmodule
