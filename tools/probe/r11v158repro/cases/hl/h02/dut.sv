// § arrQueryFoldAtBound158
module dut #(parameter logic [3:0][7:0] a = 0) (output int o);
  localparam int L = $left(a);
  localparam int R = $right(a);
  assign o = L + R;
endmodule
