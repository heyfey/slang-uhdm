// § unitParamShadowDefBind432
localparam CF = 0;
localparam W = 4;
module m(input [W-1:0] a, output o);
  localparam CF = 1;
  wire [W-1:0] t = a;
  assign o = t[CF] | a[W-1];
endmodule
