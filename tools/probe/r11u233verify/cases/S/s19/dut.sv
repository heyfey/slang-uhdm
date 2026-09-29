// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — the call in a generate block, the operand a module-level bit vector of the same name as a parameter of a child
module sub #(parameter int x = 9) (output logic [7:0] o);
  bit [5:0][1:0] y;
  wire [7:0] w = $size(y);
  assign o = w;
endmodule
module dut (output logic [7:0] o1, o2);
  bit [3:0][1:0] y;
  if (1) begin : g
    wire [7:0] w = $size(y);
    assign o1 = w;
  end
  sub u (.o(o2));
endmodule
