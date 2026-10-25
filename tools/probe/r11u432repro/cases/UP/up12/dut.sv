// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  wire CF;
  assign CF = a[1];
  assign o = CF;
endmodule
