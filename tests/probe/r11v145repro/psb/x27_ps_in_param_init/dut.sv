// § psBoundBareRefByBase145
module dut(output logic [4:0] o);
  localparam logic [31:0] K = 32'h12345678;
  localparam int W = 8;
  localparam int L = 4;
  localparam logic [4:0] Q = K[W:L];
  assign o = Q;
endmodule
