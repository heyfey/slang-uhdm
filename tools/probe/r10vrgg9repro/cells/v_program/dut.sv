program pr #(parameter bit P = 0)();
  logic [7:0] arr[2];
  initial arr[0] = (P) ? 42 : 7;
endprogram
module top;
  pr #(.P(1)) u_a();
endmodule
