// § unsignedScalarVecTsAtKeyword137 (refinement R11V137_DEFWIRE_OFF)
// case dw04: a wire logic unsigned body net in a parameterized sub-module
module sub #(parameter int P = 1) (input logic a, output logic b);
  wire logic unsigned w;
  assign w = a;
  assign b = w;
endmodule
module top(input logic a, output logic b); sub #(.P(2)) u(.a(a), .b(b)); endmodule
