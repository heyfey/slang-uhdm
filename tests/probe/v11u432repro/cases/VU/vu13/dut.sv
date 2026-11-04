// § unitParamShadowDefBind432
localparam CF = 0;
module sub(input a, output o);
  assign o = a;
endmodule
module m #(parameter CF = 1)(input [3:0] a, output o);
  sub u(.a(a[CF]), .o(o));
endmodule
module top(input [3:0] a, output o);
  m #(.CF(3)) i(.a(a), .o(o));
endmodule
