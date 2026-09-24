module top #(parameter P = 1) (output int a);
  assign a = $clog2(P + 2);
endmodule
