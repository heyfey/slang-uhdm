// § defPortPackedTsKeepsWholeSpan200
module m01(p, q, r);
  input wire [1:0][3:0] p;
  output logic [2:0][1:0][1:0] q;
  inout wire [1:0][1:0] r;
  assign q = {p, p[0]};
endmodule
