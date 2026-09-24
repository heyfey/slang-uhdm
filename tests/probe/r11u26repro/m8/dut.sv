// m8 — THE NESTED WRITE FROM A PATTERN PARAMETER, beside the landed nested
// stamp law (r11u24 § pkgStructFuncAssembleNested24).  `c.u.v = UU` writes
// BELOW the first level from a pattern parameter: the producer stamps the
// FIRST-LEVEL member `u` with the reduced RHS whole, so the leftover is UU's
// operation on `u` itself.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t v; int unsigned w; } mid_t;
  typedef struct packed { mid_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u.v = UU; c.u.w = 7; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
  // AND THE OTHER ORDER, its own typedef
  typedef struct packed { mid_t un; int unsigned dn; } n_t;
  function automatic n_t mk2();
    n_t c; c.un.w = 7; c.un.v = UU; c.dn = 64; return c;
  endfunction
  localparam n_t N = mk2();
endpackage

module kid #(
    parameter pk::c_t P = pk::C,
    parameter pk::n_t Q = pk::N
) (output logic o);
  localparam pk::mid_t S1 = P.u;
  localparam pk::mid_t S2 = Q.un;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
