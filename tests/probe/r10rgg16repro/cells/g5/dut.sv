// g5 — DEPTH and NESTING: a gen scope inside a gen scope, and an actual
// declared in the OUTER gen scope but used by an instance in the INNER one;
// plus a module-scope instance whose actual is declared in an enclosing
// generate block (illegal upward) is NOT tested — only legal downward reads.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic o0, output logic o1, output logic o2);
  ifc #(16, 3) inst ();
  if (1) begin : go
    ifc #(16, 3) oinst ();
    // c1  actual in THIS gen scope
    child u1 (.p(oinst), .o(o0));
    if (1) begin : gi
      // c2  actual in the ENCLOSING gen scope (one level up)
      child u2 (.p(oinst), .o(o1));
      // c3  actual at MODULE scope (two levels up)
      child u3 (.p(inst), .o(o2));
    end
  end
endmodule
