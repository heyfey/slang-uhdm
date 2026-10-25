// § unitParamShadowDefBind432
localparam CF = 0;
interface ifc(input [3:0] a, output o);
  localparam CF = 1;
  assign o = a[CF];
endinterface
module m(input [3:0] a, output o);
  localparam CF = 1;
  ifc i(.a(a), .o());
  assign o = a[CF];
endmodule
