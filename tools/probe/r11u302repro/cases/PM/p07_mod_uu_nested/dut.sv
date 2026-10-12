// § modPatLeftoverCloneNoParent302
// p07: the pattern written below the first level (a2's shape)
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
  assign o = 1'b0;
endmodule
