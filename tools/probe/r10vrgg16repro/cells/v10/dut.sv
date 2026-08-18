// v10 — ACTUAL SPELLINGS the gate parses off the parse tree: a PARENTHESIZED
// actual `(inst)`, a MODPORT expression `inst.mp` at both homes, and a
// two-level passthrough where the actual is the enclosing module's own port
// re-passed from a gen scope.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module leaf (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module mid (ifc.mp p, output logic o1, output logic o2, output logic o3);
  leaf a (.p(p),      .o(o1));          // passthrough, module scope
  leaf b (.p(p),      .o(o2));          // second passthrough, module scope
  if (1) begin : g
    leaf c (.p(p),    .o(o3));          // passthrough from a gen scope
  end
endmodule

module top (output logic [5:0] o);
  ifc #(16, 3) inst ();
  leaf l1 (.p((inst)),   .o(o[0]));     // parenthesized actual, module scope
  leaf l2 (.p(inst.mp),  .o(o[1]));     // modport expression, module scope
  if (1) begin : g
    leaf l3 (.p((inst)), .o(o[2]));     // parenthesized actual, gen scope
  end
  mid m1 (.p(inst), .o1(o[3]), .o2(o[4]), .o3(o[5]));
endmodule
