// The NARROWED landed law (§ genCaSysCallArgBinds22): a module Lhs with a
// $signed argument inside an OPERATION Rhs -- the cell c26 convicts, but at
// TOP level with a gen-local operand.
module top(input logic [15:0] a, input logic p, output logic [33:0] o);
  logic sa;
  logic signed [33:0] res;
  if (1) begin : gb
    logic [15:0] oa;
    assign oa = a;
    assign sa = p;
    assign res = $signed({sa, oa}) * 34'sd3;
  end
  assign o = res;
endmodule
