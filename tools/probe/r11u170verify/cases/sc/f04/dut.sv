// § sizeCastCaLitMask158
module dut (output logic [7:0] p, output logic [7:0] q, output logic [7:0] r, output logic [7:0] t);
  typedef enum int { E0, E1, E2, E3 } e_t;
  assign p = 2'('1);
  assign q = 2'(1'b1 << 2 | 3);
  assign r = 3'($clog2(100));
  assign t = 1'(E3);
endmodule
