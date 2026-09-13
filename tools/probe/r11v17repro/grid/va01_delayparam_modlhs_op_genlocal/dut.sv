// THE DELAY CLONE. writeCont_assign clones FIRST for a ref_obj delay
// (cloned=true), so the Lhs-bound operation arm's `if (cloned == false)`
// is FALSE and reduceExpr NEVER runs: the Rhs keeps its definition bindings.
module top(input logic [31:0] a, output logic [31:0] o);
  parameter DLY = 3;
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign #DLY mv = src | 32'd1;
  end
  assign o = mv;
endmodule
