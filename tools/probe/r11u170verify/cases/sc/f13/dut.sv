// § sizeCastCaLitMask158
module dut (output logic [7:0] p, output logic [7:0] q, output logic [7:0] r);
  assign p = 3'(2'(7) + 1);
  assign q = signed'(2'(3));
  assign r = 2'(unsigned'(-1));
endmodule
