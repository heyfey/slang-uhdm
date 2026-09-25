// § sizeCastCaLitMask158
module sub (output logic [3:0] p);
  assign p = 2'(7);
endmodule
module dut (output logic [3:0] p);
  sub u(.p(p));
endmodule
