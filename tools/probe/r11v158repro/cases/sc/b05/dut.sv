// § sizeCastCaLitMask158
module dut (output logic [7:0] p, output logic [7:0] q, output logic [7:0] r);
  localparam int unsigned U = 7;
  assign p = 2'(U + 1);
  assign q = 3'(1 << 3);
  assign r = 1'(3);
endmodule
