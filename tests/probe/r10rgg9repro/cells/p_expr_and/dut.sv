module m #(
  parameter bit P = 1, parameter bit Q = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (P && Q) ? {2{sig}} : '0;

endmodule
module top;
  m #(.P(1), .Q(0)) u_a();
endmodule
