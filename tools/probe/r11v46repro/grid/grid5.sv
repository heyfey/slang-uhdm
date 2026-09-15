// v11u46 ADVERSARIAL GRID-5 — the SAME signing-cast gen_for at 1, 2 and 3
// instances, with DIFFERENT parameter overrides per instance (def view emitted
// once, elaborated view once per instance).  Plus an interface carrying the
// same loop instantiated three times.
package p5v;
  parameter int unsigned PL = 3;
endpackage

module cell5
  import p5v::*;
#(
    parameter int unsigned NL = 2
) (
    input  logic [7:0] in_i,
    output logic [7:0] out_o
);
  // the corpus shape, verbatim
  for (genvar level = 0; unsigned'(level) < NL; level++) begin : g_lvl
    localparam int unsigned IX = 2 ** (level + 1) - 1;
    assign out_o[level] = in_i[IX[2:0]];
  end
  // a package-param bound under the cast (fold face) in the same loop set
  for (genvar q = 0; q < unsigned'(PL); q++) begin : g_q
    assign out_o[q + 4] = in_i[q];
  end
endmodule

interface if5 #(parameter int unsigned NI = 2) ();
  for (genvar p = 0; unsigned'(p) < NI; p++) begin : g_p
    logic w;
  end
endinterface

module grid5 (input logic [7:0] i_i, output logic [7:0] o_o);
  cell5 #(.NL(1)) u1 (.in_i(i_i), .out_o());
  cell5 #(.NL(2)) u2 (.in_i(i_i), .out_o());
  cell5 #(.NL(3)) u3 (.in_i(i_i), .out_o(o_o));
  if5   #(.NI(1)) w1 ();
  if5   #(.NI(2)) w2 ();
  if5   #(.NI(3)) w3 ();
endmodule
