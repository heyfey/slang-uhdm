// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = 2*S;
endpackage
module top(output int o);
  import pk::*;
  assign o = BY;
endmodule
