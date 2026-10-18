// § macroArgParamOrder404
`define DECL(n) logic n;
`define DECLP(n) logic n``_x;
module top;
  logic a;
  `DECL(b)
  logic c;
  `DECLP(d)
  logic e;
  `DECL(f) `DECL(g)
endmodule
