// § psBoundBareRefByBase145
module dut(input logic [31:0] a, input logic [31:0] b, output logic o);
  localparam int W = 6;
  localparam int L = 2;
  assign o = b[a[W:L]];
endmodule
