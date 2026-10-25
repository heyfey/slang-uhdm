// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  localparam CF = 1;
  assign o = a[CF];
endmodule
