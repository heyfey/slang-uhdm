// v8 — MULTIPLICITY: 1..3 children in the same scope, a child with TWO
// interface ports fed by the SAME instance, and a child with two ports fed by
// DIFFERENT instances (one in scope, one out of scope).  The gate's loop
// `break`s at the FIRST matching port -- this cell is what tests that.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module two (ifc.mp a, ifc.mp b, output logic o);
  assign o = a.sig[0] ^ b.sig[0];
endmodule

module top (output logic [7:0] o);
  ifc #(16, 3) inst ();
  child u1 (.p(inst), .o(o[0]));
  child u2 (.p(inst), .o(o[1]));
  child u3 (.p(inst), .o(o[2]));
  two   t1 (.a(inst), .b(inst), .o(o[3]));
  if (1) begin : g
    ifc #(16, 3) ginst ();
    // a = OUT of scope (module level), b = IN scope (this gen block)
    two t2 (.a(inst),  .b(ginst), .o(o[4]));
    // a = IN scope, b = OUT of scope  (the reverse order)
    two t3 (.a(ginst), .b(inst),  .o(o[5]));
    child u4 (.p(ginst), .o(o[6]));
    child u5 (.p(inst),  .o(o[7]));
  end
endmodule
