// § sizeCastCaLitMask158
module dut (output logic signed [7:0] p, output int q);
  assign p = 2'(3);
  assign q = 3'(5);
endmodule
