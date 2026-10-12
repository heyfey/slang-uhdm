// § pkgPatLeftoverSrcPkgListing302
// vq05: two packages, the builder reads one qualified and the other through its import
package pa;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam in_t UA = '{a: 1, b: 2};
endpackage
package pb;
  typedef struct packed { pa::in_t u; pa::in_t v; } c_t;
  localparam pa::in_t UB = '{a: 3, b: 4};
endpackage
module dut import pa::*; import pb::*; (output logic o);
  function automatic c_t mk();
    c_t c; c.u = pa::UA; c.v = UB; return c;
  endfunction
  localparam c_t L = mk();
  localparam in_t MS = L.u;
  assign o = 1'b0;
endmodule
