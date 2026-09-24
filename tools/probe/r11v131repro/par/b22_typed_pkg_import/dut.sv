// § paramFoldParenSpan131
package pk;
  parameter int A = (8);
  parameter int B = (A * 2);
endpackage
module top (output logic [31:0] o);
  import pk::*;
  assign o = B + A;
endmodule
