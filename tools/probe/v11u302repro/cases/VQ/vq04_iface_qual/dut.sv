// § pkgPatLeftoverSrcPkgListing302
// vq04: a qualified read in an interface builder, the package imported into the interface
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage
interface ifc;
  import pk::*;
  function automatic c_t mk();
    c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  localparam c_t L = mk();
  logic s;
endinterface
module dut(output logic o);
  ifc i0 ();
  assign o = i0.s;
endmodule
