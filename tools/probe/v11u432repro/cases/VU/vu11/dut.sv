// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output [3:0] o);
  localparam CF = 1;
  assign #CF o = a;
  wire [3:0] w = a << CF;
endmodule
