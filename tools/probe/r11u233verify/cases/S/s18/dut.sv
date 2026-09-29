// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — the call in a generate block, the operand a module-level variable shadowed by a local of the block
module dut (output logic [7:0] o1, o2);
  bit [3:0][1:0] x;
  if (1) begin : g
    bit [2:0][4:0] x;
    wire [7:0] w = $size(x);
    assign o1 = w;
  end
  wire [7:0] w2 = $size(x);
  assign o2 = w2;
endmodule
