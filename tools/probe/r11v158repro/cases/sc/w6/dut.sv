// § sizeCastSignedLitAbstain158v
module dut (output logic [7:0] p, output logic [7:0] q);
  assign p = 2'(-3'sd1);
  assign q = 3'(4'sd7);
endmodule
