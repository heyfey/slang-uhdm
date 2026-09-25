// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [3:0] o);
  localparam int L = 4;
  logic [3:0] t;
  assign t = a[L+3:L];
  assign o = t;
endmodule
