// r10v118 arm K — the OTHER slang site that builds ConversionExpression with
// ConversionKind::Explicit: MiscExpressions.cpp:1349, a checker/assertion
// formal whose actual does not match its declared type.
checker Palisade(string Legend, int Rung);
  always_comb $display("%s %0d", Legend, Rung);
endchecker

module Bastion #(parameter int Merlon = 5) (input logic Tick);
  string Cresset;
  always_comb Cresset = {"b", (Merlon > 2 ? "hi" : "lo")};
  Palisade Loophole(.Legend({"ck", (Merlon > 1 ? "y" : "n")}), .Rung(Merlon));
  initial $display("%s", {"i", (Merlon > 0 ? "p" : "z")});
endmodule
