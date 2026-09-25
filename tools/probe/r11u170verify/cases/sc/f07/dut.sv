// § sizeCastCaLitMask158
module dut (output bit [3:0] p, output byte q, output shortint r);
  assign p = 2'(7);
  assign q = 4'(-3);
  assign r = 3'(15);
endmodule
