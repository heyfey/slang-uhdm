// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output logic o);
  localparam CF = 1;
  always_comb o = a[CF];
endmodule
