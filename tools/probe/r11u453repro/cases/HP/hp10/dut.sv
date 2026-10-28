// § hpPartSelParenRightEnd453
interface ifc;
  logic [7:0] data;
endinterface
module top;
  ifc u();
  logic [3:0] o;
  always_comb u.data[(3):(0)] = o;
endmodule
