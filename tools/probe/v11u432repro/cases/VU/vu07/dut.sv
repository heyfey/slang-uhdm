// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  localparam CF = 1;
  logic CFv;
  assign o = a[CF] & m.CF;
endmodule
