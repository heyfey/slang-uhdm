// § psBoundBareRefByBase145
module dut(input logic [1:0][15:0] m, output logic [4:0] o);
  localparam int W = 8;
  localparam int L = 4;
  assign o = m[1][W:L];
endmodule
