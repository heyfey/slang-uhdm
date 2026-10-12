// § pkgPatLeftoverSrcPkgListing302
// vq01: a qualified package pattern read by a module builder called from a generate-block localparam
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage
module dut import pk::*; (output logic o);
  function automatic c_t mk();
    c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  if (1) begin : g
    localparam c_t L = mk();
    localparam in_t MS = L.u;
  end
  assign o = 1'b0;
endmodule
