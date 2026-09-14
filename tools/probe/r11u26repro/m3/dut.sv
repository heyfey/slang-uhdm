// m3 — THE RHS PARAMETER KINDS, one member per kind, all FIRST-LEVEL writes.
// Each member of `k_t` is written WHOLE from a parameter of a different kind;
// golden's leftover per member is whatever `getValue` hands back for that
// parameter (UHDM v1.87 ExprEval.cpp:306 `result = (any *)p->Rhs()`).
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam in_t PAT  = '{a: 11, b: 22};          // pattern -> OPERATION
  localparam in_t SPAT = '{33, 44};                // simple pattern -> OPERATION
  localparam in_t CHN  = PAT;                      // chained ref to a pattern
  localparam int unsigned SCA = 7;                 // folded scalar constant
  localparam in_t EXPR = '{a: SCA + 1, b: 5};      // pattern with a computed elem
  typedef struct packed {
    in_t p;      // <- PAT   (pattern operation)
    in_t q;      // <- SPAT  (simple pattern operation)
    in_t r;      // <- CHN   (chained)
    in_t e;      // <- EXPR
    int unsigned s;  // <- SCA (folded constant: the LANDED arm's control)
  } k_t;
  function automatic k_t mk();
    k_t c; c.p = PAT; c.q = SPAT; c.r = CHN; c.e = EXPR; c.s = SCA; return c;
  endfunction
  localparam k_t K = mk();
endpackage

module kid #(
    parameter pk::k_t P = pk::K
) (output logic o);
  localparam pk::in_t RP = P.p;
  localparam pk::in_t RQ = P.q;
  localparam int unsigned RS = P.s;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
