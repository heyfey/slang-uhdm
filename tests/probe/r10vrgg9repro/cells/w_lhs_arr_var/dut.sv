module m #(parameter int I = 0, parameter bit P = 0)();
  logic [7:0] arr[4];
  assign arr[I] = (P) ? 42 : 7;
endmodule
module top;
  m #(.I(2), .P(1)) u_a();
endmodule
