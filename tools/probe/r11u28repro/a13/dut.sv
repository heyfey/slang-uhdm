// a13 — THE VIEW SPLIT.  The holder parameter is the ACTUAL of a module
// instance's override, so the DEF listing, the elaborated module listing and
// the package listing each carry their own copy of the assembled constant and
// § asmEncFollowsRef's `<w>'b` prefix rule rides on top of the `mw / n`
// rendering.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t v; int unsigned w; } mid_t;
  typedef struct packed { mid_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u.w = 7; c.u.v = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t CFG = '{u: '{v: '{a: 0, b: 0}, w: 0}, d: 0}
) (output logic o);
  localparam pk::mid_t S = CFG.u;
  localparam int unsigned SD = CFG.d;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid #(.CFG(pk::C)) k0 (.o(o));
endmodule
