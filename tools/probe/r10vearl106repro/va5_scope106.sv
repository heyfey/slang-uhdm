// r10v106 va5_scope106 — SCOPE REACHABILITY of `applyCaCastAdjust106`'s walk.
// The walk descends TopModules -> Cont_assigns / Gen_scope_arrays / Modules /
// Interfaces only.  Anything reached through a module ARRAY, a gen-FOR with
// several iterations, an interface nested two deep, or a module instantiated
// TWICE with different parameters is a reachability question.  MEASUREMENT ONLY.
package pv5_106;
  parameter int unsigned P8 = 8;
endpackage

interface iv5_106;
  logic [7:0] iw;
  if (1) begin : gen_ii
    assign iw = pv5_106::P8'(6'h3F);
  end
endinterface

module leaf5_106 #(parameter int unsigned LW = 8) (output logic [7:0] o);
  logic [LW-1:0] lv;
  if (1) begin : gen_leaf
    assign lv = pv5_106::P8'(6'h3F);
  end
  assign o = lv;
endmodule

module mid5_106 (output logic [7:0] o);
  logic [7:0] mv;
  if (1) begin : gen_mid
    assign mv = pv5_106::P8'(6'h3F);
    leaf5_106 #(.LW(4)) u_deep ();
  end
  iv5_106 u_ifm ();
  assign o = mv;
endmodule

module va5_scope106 (output logic [7:0] o1, output logic [7:0] o2);
  logic [7:0] top_a, top_b, top_c;

  // a gen-FOR with SEVERAL iterations: one record per iteration fullname
  for (genvar i = 0; i < 3; i++) begin : g_loop
    if (i == 0) begin : g_in0
      assign top_a = pv5_106::P8'(6'h3F);
    end
  end

  // the same module instantiated TWICE with DIFFERENT Lhs widths
  leaf5_106 #(.LW(4))  u_l4 (.o(o1));
  leaf5_106 #(.LW(16)) u_l16 (.o(o2));

  // an INSTANCE ARRAY holding a gen scope
  leaf5_106 #(.LW(8)) u_arr [2:0] ();

  // a module two levels down, and an interface inside it
  mid5_106 u_mid ();

  if (1) begin : g_topif
    assign top_b = pv5_106::P8'(6'h3F);
  end
  assign top_c = pv5_106::P8'(6'h3F);   // module body control
endmodule
