// § impElabArithWholeSpan145
package pk;
  localparam int S = 32;
  localparam int BY = S % 5;
endpackage
module top(output logic [1:0] o);
  import pk::*;
  logic [BY-1:0] w;
  assign w = '1;
  assign o = w;
endmodule
