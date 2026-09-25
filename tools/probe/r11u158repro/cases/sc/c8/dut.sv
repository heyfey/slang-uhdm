// § sizeCastCaSignedSize158
module dut (output logic [3:0] p);
  localparam int V = 7;
  assign p = 2'(V);
endmodule
