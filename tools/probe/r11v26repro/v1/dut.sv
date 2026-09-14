// v1 — CROSS-SCOPE THE OTHER WAY.  The builder AND the pattern parameter live
// in the package; the HOLDER parameter lives in the module and calls `mk()`
// through a wildcard import.  `evalFuncWholeReads26` scans the PARAMETER's own
// parent scope (the package) for a parameter initialized by a recognized
// builder — there is none — so the new trigger CANNOT fire here.  What does
// golden do?
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
endpackage

module dut(output logic o);
  import pk::*;
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  assign o = 1'b0;
endmodule
