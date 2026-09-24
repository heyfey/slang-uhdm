// § paramFoldParenSpan131
package pk;
  parameter A = (8);
  parameter B = (A * 2);
endpackage
module top (output logic [31:0] o);
  import pk::*;
  assign o = B + A;
endmodule
