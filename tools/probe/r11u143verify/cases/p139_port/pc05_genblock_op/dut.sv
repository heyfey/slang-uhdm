// § connLeftmostLeafElab139
// case pc05: an operation actual on an instance inside a generate block
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic p, input logic q, output logic y);
  if (1) begin : g
    sub u(.a(p ^ q), .y(y));
  end
endmodule
