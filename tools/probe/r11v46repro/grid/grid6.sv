// v11u46 ADVERSARIAL GRID-6 — the walkers (bindGenvar / foldPkgLoopRefs) under
// nesting: casts over mixed genvar+package-param arguments, double casts,
// outer-genvar reads in an inner loop, cast-only conditions, and a module ARRAY
// instance of the whole thing.
package p6v;
  parameter int unsigned PK = 4;
endpackage

module cell6
  import p6v::*;
#(
    parameter int unsigned NB = 3
) (
    input  logic [7:0] in_i,
    output logic [7:0] out_o
);
  // BA: the cast argument mixes a GENVAR and a PACKAGE parameter
  for (genvar ba = 0; unsigned'(ba + PK) < NB + 4; ba++) begin : g_ba
    assign out_o[0] = in_i[0];
  end

  // BB: DOUBLE cast over the genvar
  for (genvar bb = 0; unsigned'(unsigned'(bb)) < NB; bb++) begin : g_bb
    assign out_o[1] = in_i[1];
  end

  // BC: signed' over a genvar, package param on the other side
  for (genvar bc = 0; signed'(bc) < signed'(PK); bc++) begin : g_bc
    assign out_o[2] = in_i[2];
  end

  // BD: the whole condition IS the cast
  for (genvar bd = 0; unsigned'(bd < NB); bd++) begin : g_bd
    assign out_o[3] = in_i[3];
  end

  // BE: an OUTER genvar read inside an INNER loop's cast
  for (genvar be = 0; be < NB; be++) begin : g_be
    for (genvar bf = 0; unsigned'(be) + unsigned'(bf) < NB; bf++) begin : g_bf
      assign out_o[4] = in_i[4];
    end
  end

  // BG: cast in the condition of a gen_for nested inside a gen_if
  if (NB > 1) begin : g_bg
    for (genvar bg = 0; unsigned'(bg) < NB; bg++) begin : g_bg2
      assign out_o[5] = in_i[5];
    end
  end

  // BH: init AND condition both cast, decrementing loop
  for (genvar bh = unsigned'(PK); unsigned'(bh) > 0; bh--) begin : g_bh
    assign out_o[6] = in_i[6];
  end

  // BI: the genvar name shadows a module-level net name
  logic [7:0] bi;
  assign bi = in_i;
  for (genvar bi = 0; unsigned'(bi) < NB; bi++) begin : g_bi
    assign out_o[7] = in_i[7];
  end
endmodule

module grid6 (input logic [7:0] i_i, output logic [7:0] o_o);
  cell6 #(.NB(2)) u_one (.in_i(i_i), .out_o(o_o));
  cell6 #(.NB(3)) u_arr [2:0] (.in_i(i_i), .out_o());
endmodule
