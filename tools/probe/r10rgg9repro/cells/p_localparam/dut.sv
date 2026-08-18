module m #(
  parameter bit P = 1
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  localparam bit LP = P & 1'b1;

  assign arr[0] = (LP) ? {2{sig}} : '0;

endmodule
module top;
  m #(.P(0)) u_a();
  m #(.P(1)) u_b();
endmodule
