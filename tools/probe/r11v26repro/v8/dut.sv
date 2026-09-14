// v8 — AN OVERRIDABLE HOLDER, ACTUALLY OVERRIDDEN.  `CFG` is a module
// `parameter` whose DEFAULT is the builder call and whose instance ACTUAL is a
// literal pattern.  The DEF listing must keep the builder's answer and the
// ELABORATED listing the override — the view split, over this law's own
// leftover.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
endpackage

module kid #(
    parameter pk::c_t CFG = pk::mk()
) (output logic o);
  localparam pk::in_t S = CFG.u;
  localparam int unsigned D = CFG.d;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
  kid #(.CFG('{u: '{a: 7, b: 8}, d: 9})) k1 (.o());
endmodule
