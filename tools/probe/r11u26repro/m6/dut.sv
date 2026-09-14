// m6 — THE SHARE ACROSS THE VIEW SPLIT AND ACROSS TWO STAMPERS.  Two distinct
// builders, two distinct struct typedefs, BOTH writing a member whole from the
// SAME pattern parameter UU.  If golden's leftover is the shared object, both
// typespec_members point at ONE operation; the def (allPackages) listing is
// the other half of the split.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  typedef struct packed { in_t v; int unsigned e; } g_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mkA();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  function automatic g_t mkB();
    g_t g; g.v = UU; g.e = 65; return g;
  endfunction
  localparam c_t CA = mkA();
  localparam g_t CB = mkB();
endpackage

module kid #(
    parameter pk::c_t P1 = pk::CA,
    parameter pk::g_t P2 = pk::CB
) (output logic o);
  localparam pk::in_t S1 = P1.u;
  localparam pk::in_t S2 = P2.v;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
