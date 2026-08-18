module m #(
  parameter logic [3:0] Q = 4'b0001
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (Q[0]) ? 42 : 7;

endmodule
module top;
  m u_a();
endmodule
