// § impPaLhsDisjointClone133
package pa; parameter int W = 8; endpackage
package pb; import pa::*; parameter int W2 = W * 2; endpackage
package pc; import pb::*; typedef logic [W2-1:0] t_t; endpackage
module top(output int o);
  pc::t_t c;
  assign c = '0;
  assign o = $bits(c);
endmodule
