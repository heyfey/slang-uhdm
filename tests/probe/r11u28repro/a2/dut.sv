// a2 — THE MODULE HOLDER of a1's face (modelled on r11u26 `m4`: only the
// typedefs live in the package).  The assembly runs through
// § modStructFuncAssembleBin's own bits instead of the package arm's, and the
// `mw / n` rendering must reach it too.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t v; int unsigned w; } mid_t;
  typedef struct packed { mid_t u; int unsigned d; } c_t;
endpackage

module dut(output logic o);
  localparam pk::in_t UU = '{a: 11, b: 22};
  function automatic pk::c_t mk();
    pk::c_t c; c.u.w = 7; c.u.v = UU; c.d = 64; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::mid_t MS = L.u;
  localparam int unsigned MD = L.d;
  kid #(.CFG(L)) k0 (.o(o));
endmodule

module kid #(
    parameter pk::c_t CFG = '{u: '{v: 0, w: 0}, d: 0}
) (output logic o);
  localparam pk::mid_t S = CFG.u;
  assign o = 1'b0;
endmodule
