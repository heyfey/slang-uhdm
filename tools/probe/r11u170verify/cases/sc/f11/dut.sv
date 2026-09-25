// § sizeCastSignedLitAbstain158v
module dut (output logic [7:0] p, output logic [7:0] q, output logic [3:0] r);
  assign p = 2'(4'sb1011);
  assign q = 3'(8'shFF);
  assign r = 2'(-4'sd3);
endmodule
