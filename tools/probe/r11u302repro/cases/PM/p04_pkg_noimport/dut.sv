// § pkgPatLeftoverSrcPkgListing302
// p04: CONTROL - qualified read, no import into the module (no copy to prefer)
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 5, b: 6};
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.u = pk::UU; c.d = 7; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  assign o = 1'b0;
endmodule
