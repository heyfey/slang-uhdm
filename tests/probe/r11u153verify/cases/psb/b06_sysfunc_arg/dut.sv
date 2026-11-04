// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output int o);
  localparam int H = 7;
  localparam int L = 4;
  assign o = $countones(a[H:L]);
endmodule
