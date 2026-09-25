// § arrQueryParamArgOnly158v
module dut (output int o);
  reg [3:0] v;
  bit [0:6] w;
  localparam int H = $high(v);
  localparam int L = $left(w);
  localparam int R = $right(w);
  assign o = H + L + R;
endmodule
