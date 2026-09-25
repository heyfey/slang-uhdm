// § sizeCastCaLitMask158
module dut (output logic [7:0] p, output logic [7:0] q);
  assign p = 6'(-3) ;
  assign q = 4'(3 > 1);
endmodule
