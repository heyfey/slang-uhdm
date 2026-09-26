// § hpDotWsTrimmed167 — a generate-array element path with blanks around the dot
module top (input logic [1:0] a, output logic y);
  for (genvar i = 0; i < 2; i++) begin : g
    wire x = a[i];
  end
  assign y = g[1] . x;
endmodule
