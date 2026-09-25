// § arrQueryFoldAtBound158
module dut #(parameter [2:1] a = 0, parameter int H = $high(a)) (output int o);
  assign o = H;
endmodule
