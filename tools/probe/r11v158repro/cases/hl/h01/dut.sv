// § arrQueryParamArgOnly158v
module dut (output int o);
  logic [7:0] mem [0:3];
  localparam int H = $high(mem);
  assign o = H;
endmodule
