// n6 — THREE LEVELS.  `c.u.v.a = 3` — does the FIRST path element after the
// local still decide the stamped member?
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } lo_t;
  typedef struct packed { lo_t v; int unsigned w; } mid_t;
  typedef struct packed { mid_t u; int unsigned d; } top_t;
  function automatic top_t mk();
    top_t c; c.u.v.a = 3; c.u.v.b = 32; c.u.w = 7; c.d = 64; return c;
  endfunction
  localparam top_t C = mk();
endpackage

module kid #(
    parameter pk::top_t CFG = pk::C
) (output logic o);
  localparam pk::mid_t M = CFG.u;
  localparam pk::lo_t  V = CFG.u.v;
  localparam int       A = CFG.u.v.a;
  localparam int       D = CFG.d;
  assign o = ^{M[0], V[0], A[0], D[0]};
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
