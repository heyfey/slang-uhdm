module m #(parameter bit P = 0)();
  logic arr[2];
  assign (strong0, strong1) arr[0] = (P) ? 1'b1 : 1'b0;
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
