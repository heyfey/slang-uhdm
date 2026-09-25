// § sizeCastCaSignedSize158
localparam int V = 7;
localparam int N = -1;
module dut (output logic [3:0] p, output logic [7:0] r);
  assign p = 2'(V);
  assign r = 3'(N);
endmodule
