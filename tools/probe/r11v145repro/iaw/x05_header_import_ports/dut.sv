// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S / 8;
endpackage
module top import pk::*; #(parameter int Q = 1) (output logic [BY-1:0] o);
  assign o = '0;
endmodule
