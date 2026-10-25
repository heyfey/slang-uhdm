// § unitParamShadowDefBind432
localparam CF = 1;
module m(input [3:0] a, output [CF:0] o);
  localparam CF = 2;
  logic [CF:0] x;
  assign x = a[2:0];
  assign o = x[1:0];
endmodule
