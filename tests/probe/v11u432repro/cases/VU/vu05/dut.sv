// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  localparam CF = 1;
  logic x [CF+1];
  assign x[0] = a[CF];
  assign o = x[0];
endmodule
