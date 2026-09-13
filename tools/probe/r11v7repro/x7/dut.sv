// v11u7 arm x7 — the SAME nested-aggregate default reached through every
// holder the corpus witnesses use, but with an OVERRIDE that differs from the
// declaration default, and a second interface whose port view is reached
// through a generate-for.  Checks that the law still shows the DECLARATION's
// tree (r11u4's port-view rule) when the instantiation overrides with a
// DIFFERENT value, and that a named-modport view stays exempt.
package q7;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
  localparam cfg_t DEF = '{BUS: '{DAT: 32}};
  localparam cfg_t OTH = '{BUS: '{DAT: 64}};
endpackage
interface xif #(parameter q7::cfg_t CFG = q7::DEF);
  localparam int unsigned W = CFG.BUS.DAT;
  logic [W-1:0] d;
  modport mp (input d);
endinterface
module leaf (xif p, output logic o);
  assign o = p.d[0];
endmodule
module mleaf (xif.mp q, output logic o);
  assign o = q.d[0];
endmodule
module top (output logic [3:0] o);
  xif #(q7::OTH) uo ();
  xif ud ();
  leaf  a0 (.p(uo), .o(o[0]));
  leaf  a1 (.p(ud), .o(o[1]));
  mleaf m0 (.q(uo.mp), .o(o[2]));
  for (genvar i = 0; i < 1; i++) begin : g
    leaf a2 (.p(uo), .o(o[3]));
  end
endmodule
