module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  localparam logic PX = 1'bx;

  assign arr[0] = (PX) ? 42 : 7;

endmodule
module top;
  m #(.P(0)) u_a();
endmodule
