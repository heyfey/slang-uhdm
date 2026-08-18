module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign #1 arr[0] = (P) ? 42 : 7;
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
