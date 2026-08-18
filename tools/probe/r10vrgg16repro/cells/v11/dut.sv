// v11 — the `.*` WILDCARD connection, which findConnSyntax cannot see (it is a
// WildcardPortConnection, not a NamedPortConnection), so the gate DECLINES.
// Does golden drop there?  Module scope and gen scope, plus a named control.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [3:0] o);
  ifc #(16, 3) p ();
  logic o0, o1, o2;
  child u1 (.*, .o(o[0]));            // wildcard, module scope
  if (1) begin : g
    child u2 (.*, .o(o[1]));          // wildcard, gen scope, actual OUTSIDE
    ifc #(16, 3) q ();
    child u3 (.p(q), .o(o[2]));       // named control, actual INSIDE
  end
  child u4 (.p(p), .o(o[3]));         // named control, module scope
endmodule
