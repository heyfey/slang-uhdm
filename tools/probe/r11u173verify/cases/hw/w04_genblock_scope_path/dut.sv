// § hpDotWsTrimmed167 — blanks around the dot of a generate-scope path read at module level
module top (input logic a, output logic y);
  if (1) begin : g
    wire x = a;
  end
  assign y = g . x;
endmodule
