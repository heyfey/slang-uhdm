module s(input logic [7:0] i);
endmodule
module m #(
  parameter bit P = 0
)();
  logic sig;
  s u_s(.i((P) ? {2{sig}} : '0));
endmodule
module top;
  m #(.P(0)) u_a();
endmodule
