// § unitParamShadowDefBind432
localparam CF = 0;
module m #(parameter CF = 2) (input [3:0] a, output o);
  assign o = a[CF];
endmodule
