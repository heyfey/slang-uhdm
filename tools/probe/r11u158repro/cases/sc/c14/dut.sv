// § sizeCastCaLitMask158
module dut (output logic [7:0] p, output logic [7:0] q);
  assign p = 2'(3 + 4);
  assign q = 4'(8'hff) + 1;
endmodule
