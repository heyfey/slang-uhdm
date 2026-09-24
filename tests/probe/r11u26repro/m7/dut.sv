// m7 — CROSS-SCOPE: the pattern parameter lives in a package, the builder and
// the holder in the module.  `getValue` walks the instance chain by NAME with
// the `pk::UU` qualifier (ExprEval.cpp:272 tokenizeMulti), so the leftover is
// still the PACKAGE parameter's own elaborated Rhs object.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage

module dut(output logic o);
  import pk::*;
  function automatic pk::c_t mk();
    pk::c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  assign o = 1'b0;
endmodule
