module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  localparam int A = 4;
  localparam int B = A + 1;

  assign arr[0] = (P) ? A : 7;

endmodule
module top;
  m #(.P(1)) u_a();
endmodule
