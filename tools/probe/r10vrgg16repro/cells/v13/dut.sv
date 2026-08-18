// v13 — a PARAMETERIZED interface nested inside another interface, whose own
// interface port is fed from a gen scope.  This is the ModuleEmit.cpp:27794
// `nestedIfaceView` call site (portView = the ENCLOSING instance), the one arm
// of the gate whose `portView->getParentScope()` is an INTERFACE body.
interface leafif #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

interface midif #(parameter int MW = 4) (leafif.mp p);
  logic [MW-1:0] q;
  assign q[0] = p.sig[0];
  modport mp (input q);
endinterface

module child (midif.mp m, output logic o);
  assign o = m.q[0];
endmodule

module top (output logic [2:0] o);
  leafif #(16, 3) li ();
  midif #(6) mi (.p(li));                 // module scope, actual in scope
  child u1 (.m(mi), .o(o[0]));
  if (1) begin : g
    midif #(6) mig (.p(li));              // gen scope, actual OUT of scope
    child u2 (.m(mig), .o(o[1]));
    child u3 (.m(mi),  .o(o[2]));         // gen scope, actual OUT of scope
  end
endmodule
