// n4 — THE MODULE HOLDER.  The nested-write builder and its localparam live in
// a MODULE; only the typedefs come from the package (the $root typedef is
// n11's question).
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage

module kid #(
    parameter pk::c_t CFG = '{u: '{a: 0, b: 0}, d: 0}
) (output logic o);
  localparam pk::in_t SUB  = CFG.u;
  localparam int      DEEP = CFG.u.b;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.u.a = 3; c.u.b = 32; c.d = 64; return c;
  endfunction
  localparam pk::c_t  L  = mk();
  localparam pk::in_t MS = L.u;
  localparam int      MD = L.u.b;
  kid #(.CFG(L)) k0 (.o(o));
endmodule
