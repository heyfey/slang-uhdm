// § hpDotWsTrimmed167 — a `$root`-anchored path with no blanks (the control of w07)
module top (input logic a, output logic y);
  logic s;
  assign s = a;
  assign y = $root.top.s;
endmodule
