module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  logic a1, b1;
  assign {a1, b1} = (P) ? {2{sig}} : '0;

endmodule
module top;
  m #(.P(0)) u_a();
endmodule
