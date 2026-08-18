module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  localparam int Z = (P) ? 3 : 4;

  assign arr[0] = Z;

endmodule
module top;
  m #(.P(0)) u_a();
endmodule
