// § importNetTsToInitEnd183
package p;
  logic [7:0] lim = 8'd12;
  int cnt = 3 + 4;
endpackage
module top(output int o);
  import p::*;
  assign o = cnt + lim;
endmodule
