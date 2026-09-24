// § unsignedScalarVecTsAtKeyword137 (refinement R11V137_DEFWIRE_OFF)
// case dw05: an attributed wand logic unsigned body net
module top(input logic a, output logic b);
  (* keep *) wand logic unsigned k;
  assign k = a;
  assign b = k;
endmodule
