// § hpDotWsTrimmed167 — no blanks (the control of w04)
module top (input logic a, output logic y);
  if (1) begin : g
    wire x = a;
  end
  assign y = g.x;
endmodule
