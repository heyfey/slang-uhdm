// § pkgPatLeftoverSrcPkgListing302
// vq02: the package pattern is itself initialised from another package's parameter; read qualified
package p0;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam in_t BASE = '{a: 3, b: 4};
endpackage
package pk;
  typedef struct packed { p0::in_t u; int unsigned d; } c_t;
  localparam p0::in_t UU = p0::BASE;
endpackage
module dut import pk::*; (output logic o);
  function automatic c_t mk();
    c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  localparam c_t L = mk();
  localparam p0::in_t MS = L.u;
  assign o = 1'b0;
endmodule
