// v4 — INTERFACE-IN-INTERFACE.  An interface that itself takes an interface
// port (the nested-view call site, ModuleEmit.cpp:27794 passes portView), with
// the actual at the enclosing scope and inside a gen-if of the enclosing
// interface.
interface leafif #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

interface midif (leafif.mp p);
  logic q;
  assign q = p.sig[0];
  modport mp (input q);
endinterface

module child (midif.mp m, output logic o);
  assign o = m.q;
endmodule

module top (output logic [2:0] o);
  leafif #(16, 3) li ();
  midif  mi (.p(li));
  child  u1 (.m(mi), .o(o[0]));
  if (1) begin : g
    // the mid interface INSTANTIATED inside a gen scope, its actual outside
    midif mig (.p(li));
    child u2 (.m(mig), .o(o[1]));
  end
  if (1) begin : g2
    // the child inside a gen scope, its actual (mi) outside
    child u3 (.m(mi), .o(o[2]));
  end
endmodule
