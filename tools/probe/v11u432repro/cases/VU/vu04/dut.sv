// § unitParamShadowDefBind432
localparam W = 2;
module sub #(parameter P = 1)(input [3:0] a, output o);
  assign o = a[P];
endmodule
module m(input [3:0] a, output o);
  localparam W = 3;
  sub #(.P(W)) u(.a(a), .o(o));
endmodule
