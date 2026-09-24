// § unsignedScalarVecTsAtKeyword137 (refinement R11V137_DEFWIRE_OFF)
// case dw02: wor and uwire logic unsigned body nets in a sub-module
module sub(input logic a, output logic b);
  wor logic unsigned x;
  uwire logic unsigned u;
  assign x = a;
  assign u = x;
  assign b = u;
endmodule
module top(input logic a, output logic b); sub s(.a(a), .b(b)); endmodule
