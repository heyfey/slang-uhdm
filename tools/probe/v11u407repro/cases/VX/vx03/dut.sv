// § typedParamXzLitSize407
interface ifc;
  parameter int ma = 1'bx;
  int v;
  assign v = ma;
endinterface
module top(output int o);
  ifc i();
  assign o = i.v;
endmodule
