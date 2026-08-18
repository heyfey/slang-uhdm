// g1 — the CORE axis: does the port view's connection actual live in the
// INSTANTIATING SCOPE?  One parameterization only (single tuple).
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic o0, output logic o1, output logic o2, output logic o3);
  ifc #(16, 3) inst ();
  // c1  module scope, actual = a named interface instance IN THIS SCOPE
  child u1 (.p(inst), .o(o0));
  // c2  gen-if scope, actual declared OUTSIDE the gen scope
  if (1) begin : g2
    child u2 (.p(inst), .o(o1));
  end
  // c3  gen-if scope carrying its OWN interface instance
  if (1) begin : g3
    ifc #(16, 3) ginst ();
    child u3 (.p(ginst), .o(o2));
  end
  // c4  gen-for scope, actual declared OUTSIDE
  for (genvar i = 0; i < 1; i++) begin : g4
    child u4 (.p(inst), .o(o3));
  end
endmodule
