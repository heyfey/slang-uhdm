// § arrQueryParamArgOnly158v
module dut (input logic [5:2] a, output int o);
  localparam int H = $high(a);
  localparam int L = $low(a);
  assign o = H + L;
endmodule
