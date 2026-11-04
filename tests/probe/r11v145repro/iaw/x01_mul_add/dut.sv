// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S*2+1;
endpackage
module top(output int o);
  import pk::*;
  logic [BY-1:0] w;
  assign o = $bits(w);
endmodule
