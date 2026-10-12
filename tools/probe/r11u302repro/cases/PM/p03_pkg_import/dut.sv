// § pkgPatLeftoverSrcPkgListing302
// p03: the package parameter read unqualified through a wildcard import
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 1, b: 2};
endpackage
module dut import pk::*; (output logic o);
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 3; return c;
  endfunction
  localparam c_t L = mk();
  localparam in_t MS = L.u;
  assign o = 1'b0;
endmodule
