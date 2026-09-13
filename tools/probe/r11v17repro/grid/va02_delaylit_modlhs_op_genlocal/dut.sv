// CONTROL for va01: a LITERAL delay is a constant, not a ref_obj, so no
// early clone happens and reduceExpr DOES run.
module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign #5 mv = src | 32'd1;
  end
  assign o = mv;
endmodule
