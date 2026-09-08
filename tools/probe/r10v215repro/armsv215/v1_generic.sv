// r10v215 ADVERSARIAL ARM v1 — THE GENERIC INTERFACE PORT.
// ModuleEmit.cpp ~9465 sets connModport from the CONNECTION (conn.second->name)
// for an unbound generic port, and ~9495 re-points the LowConn ref_obj by
// walking `ii->Modports()`.  With a clocking-only modport as the connection the
// name can no longer be found — and § modportNeedsSimplePort215's port-view
// fallback makes the view list EVERY OTHER minted modport instead.  Neither
// path is in the implementer's grid (arm C uses declared `.mp`-qualified ports
// only).  v1a is the clocking-only connection, v1b the simple-modport control.
interface v1_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mpa (input clk);
  modport mpb (output d);
endinterface

module v1_sub (interface p);
endmodule

module top;
  v1_if i1();
  v1_sub s_c (.p(i1.mpc));
  v1_sub s_a (.p(i1.mpa));
  v1_sub s_p (.p(i1));
endmodule
