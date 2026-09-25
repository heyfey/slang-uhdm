// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [7:0] o);
  localparam int W = 8;
  localparam int L = 4;
  assign o = a[W+L-1:L];
endmodule
