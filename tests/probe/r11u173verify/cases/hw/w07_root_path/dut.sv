// § hpDotWsTrimmed167 — a `$root`-anchored path with blanks around its dots
module top (input logic a, output logic y);
  logic s;
  assign s = a;
  assign y = $root . top . s;
endmodule
