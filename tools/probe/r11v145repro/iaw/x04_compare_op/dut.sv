// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter bit BIG = S > 16;
endpackage
module top(output logic o);
  import pk::*;
  if (BIG) begin : g
    assign o = 1'b1;
  end else begin : h
    assign o = 1'b0;
  end
endmodule
