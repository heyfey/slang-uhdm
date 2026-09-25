// § sizeCastSignedLitAbstain158v
module dut (output logic [7:0] p, output logic [5:0] q);
  assign p = 3'(4'sd5);
  assign q = 2'(8'sh81);
endmodule
