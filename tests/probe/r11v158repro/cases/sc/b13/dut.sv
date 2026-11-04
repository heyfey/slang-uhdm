// § sizeCastNarrowTargetAbstain158v
module dut (output logic [1:0] p, output logic [2:0] q);
  assign p = 4'(-1);
  assign q = 8'(-3);
endmodule
