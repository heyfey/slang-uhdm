// § sizeCastCaLitMask158
module dut (output logic [3:0] p, output logic [3:0] q);
  assign p = 2'(3) + 1;
  assign q = ~2'(1);
endmodule
