// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S/8;
endpackage
module top #(parameter int Q = 1) (output int o);
  import pk::*;
  assign o = BY + Q;
endmodule
