// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  localparam CF = 1;
  typedef logic [CF:0] t_t;
  t_t q;
  assign q = a[1:0];
  assign o = q[CF];
endmodule
