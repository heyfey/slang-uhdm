// m4 — THE MODULE HOLDER of m1: the builder, the pattern parameter and the
// localparam all live in `module dut`; only the typedefs are in the package.
// The producer is holder-blind, so the leftover must be the SAME object kind.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage

module dut(output logic o);
  localparam pk::in_t UU = '{a: 11, b: 22};
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  localparam int unsigned MD = L.d;
  kid #(.CFG(L)) k0 (.o(o));
endmodule

module kid #(
    parameter pk::c_t CFG = '{u: '{a: 0, b: 0}, d: 0}
) (output logic o);
  localparam pk::in_t S = CFG.u;
  assign o = 1'b0;
endmodule
