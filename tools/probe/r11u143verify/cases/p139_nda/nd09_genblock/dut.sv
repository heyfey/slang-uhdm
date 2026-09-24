// § ndaLeftmostLeafElab139
// case nd09: a net declaration assignment inside a generate block
module top(input logic a, input logic b, output logic y);
  if (1) begin : g
    wire w = a & b;
    assign y = w;
  end
endmodule
