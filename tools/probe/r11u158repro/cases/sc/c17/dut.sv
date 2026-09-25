// § sizeCastCaSignedSize158
module dut (output logic [7:0] p, output logic [7:0] q);
  localparam logic [7:0] V = 8'd7;
  localparam int unsigned U = 7;
  assign p = 2'(V);
  assign q = 2'(U);
endmodule
