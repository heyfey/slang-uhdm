// § sizeCastCaLitMask158
module dut (output logic [7:0] p, output logic [7:0] q);
  localparam int V = 7;
  assign p = 2'(V + 0);
  assign q = 2'(-V);
endmodule
