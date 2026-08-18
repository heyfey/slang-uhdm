module sub #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : 7;
endmodule
module m #(parameter bit P = 0)();
  sub #(.P(P)) u_s();
endmodule
module top;
  m #(.P(1)) u_a();
  m #(.P(0)) u_b();
endmodule
