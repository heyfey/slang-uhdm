// v1 — CONNECTION FORM axis: named `.p(inst)`, shorthand `.p`, POSITIONAL,
// and `.*`, each at module scope and inside a gen-if.  The gate declines on
// positional and on `.*` (findConnSyntax returns null); golden may not.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [7:0] o);
  ifc #(16, 3) p ();
  ifc #(16, 3) q ();
  // named, module scope
  child u1 (.p(p), .o(o[0]));
  // shorthand `.p`, module scope
  child u2 (.p, .o(o[1]));
  // positional, module scope
  child u3 (p, o[2]);
  if (1) begin : g
    // named, gen scope, actual OUTSIDE
    child u4 (.p(p), .o(o[3]));
    // shorthand, gen scope, actual OUTSIDE
    child u5 (.p, .o(o[4]));
    // positional, gen scope, actual OUTSIDE
    child u6 (p, o[5]);
    // named, gen scope, actual INSIDE
    ifc #(16, 3) r ();
    child u7 (.p(r), .o(o[6]));
  end
  child u8 (.p(q), .o(o[7]));
endmodule
