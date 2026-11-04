// § sizeCastNarrowTargetAbstain158v
module dut (output logic [2:0] p, output logic [1:0] q);
  assign p = 6'(45);
  assign q = 3'(3'd5 + 3'd4);
endmodule
