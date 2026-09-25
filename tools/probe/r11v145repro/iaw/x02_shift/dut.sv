// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S >> 3;
endpackage
module top(output logic [3:0] o);
  import pk::*;
  logic [BY-1:0] w;
  assign w = '1;
  assign o = w;
endmodule
