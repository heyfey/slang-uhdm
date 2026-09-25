// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [8:0] o);
  localparam int W = 8;
  assign o = a[W:0];
endmodule
