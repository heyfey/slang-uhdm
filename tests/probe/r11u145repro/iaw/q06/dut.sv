// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S/8;
endpackage
module top(output int o);
  import pk::BY;
  assign o = BY;
endmodule
