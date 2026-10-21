// § octUnszElabRespell423
package p;
  parameter O = 'o17;
endpackage
module top(input int x, output int z);
  import p::*;
  always_comb z = x - O;
endmodule
