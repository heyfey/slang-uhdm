// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S/8;
endpackage
module sub(output int o);
  import pk::*;
  assign o = BY;
endmodule
module top(output int o);
  sub u(.o(o));
endmodule
