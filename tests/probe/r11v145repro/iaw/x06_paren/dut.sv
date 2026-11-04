// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = (S + 8) / 8;
endpackage
module top(output logic [7:0] o);
  import pk::*;
  logic [BY-1:0] w;
  assign w = '1;
  assign o = 8'(w);
endmodule
