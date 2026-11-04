// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S - 8;
endpackage
module top(output logic [31:0] o);
  import pk::BY;
  logic [BY-1:0] w;
  assign w = '0;
  assign o = 32'(w);
endmodule
