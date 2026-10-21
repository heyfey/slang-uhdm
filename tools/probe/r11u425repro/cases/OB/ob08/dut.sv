// § oneTickUpperBNormalized425 (control: 1'Bz, a wider binary, a signed one-bit and 'B0 keep their own forms)
module top(input a, output o, output p, output q, output r);
  assign o = a & 1'Bz;
  assign p = a | 1'sB1;
  logic [3:0] w;
  assign w = 4'B1010;
  assign q = w[0];
  assign r = a | 'B0;
endmodule
