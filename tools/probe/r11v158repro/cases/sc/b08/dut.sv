// § sizeCastCaSignedSize158
module dut (output logic [1:0] p, output logic signed [7:0] q);
  localparam int V = 7;
  assign p = 3'(V);
  assign q = 2'(V);
endmodule
