// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  localparam CF = 1;
  wire [CF:0] w;
  assign o = w[0] ^ a[0];
endmodule
