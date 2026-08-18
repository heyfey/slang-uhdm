module m #(
  parameter string S = "a"
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (S == "a") ? 42 : 7;

endmodule
module top;
  m u_a();
endmodule
