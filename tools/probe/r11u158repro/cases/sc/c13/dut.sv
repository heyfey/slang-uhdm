// § sizeCastCaLitMask158
module dut (output logic [1:0] p, output logic [7:0] q);
  assign p = 2'(3);
  assign q = 4'(-3);
endmodule
