// § hpPartSelParenRightEnd453
interface ifc;
  logic [15:0] v;
endinterface
module top;
  ifc u();
  logic [3:0] o;
  assign o = u.v[3:(0)];
endmodule
