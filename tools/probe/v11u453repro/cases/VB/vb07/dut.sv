// § hpVsParenBoundPretty453
interface ifc;
  logic [3:0][7:0] pg;
endinterface
module top;
  ifc u();
  logic [1:0] o;
  assign o = u.pg[1][(3):2];
endmodule
