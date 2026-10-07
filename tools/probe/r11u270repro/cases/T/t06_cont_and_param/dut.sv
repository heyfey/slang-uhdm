// § sysCallTimeKwNameSpan270
module top(output int o, output int p);
  assign o = $time();
  localparam int L = $bits(int);
  assign p = $urandom() + L;
endmodule
