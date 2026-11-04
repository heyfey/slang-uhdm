// § sizeCastCaLitMask158
module dut (output logic [3:0] p);
  localparam int SEL_W = 2;
  assign p = SEL_W'(3);
endmodule
