// § sizeCastCaLitMask158
module dut (output logic [3:0] p);
  wire [3:0] w = 2'(3);
  assign p = w;
endmodule
