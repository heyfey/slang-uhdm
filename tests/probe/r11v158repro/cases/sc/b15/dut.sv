// § sizeCastNarrowTargetAbstain158v
module dut (output logic p, output logic [3:0] q);
  assign p = 2'(3);
  assign q = 5'(31);
endmodule
