module m #(parameter bit P = 0)();
  localparam int A[2] = '{3, 5};
  logic [7:0] arr[2];
  assign arr[0] = (P) ? A[1] : 7;
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
