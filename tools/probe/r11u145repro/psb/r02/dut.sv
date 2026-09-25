// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [3:0] o);
  localparam int L = 4;
  assign o = a[L+3:L];
endmodule
