// § pkgPatLeftoverSrcPkgListing302
// p09: package builder and pattern, the package imported by the instantiated module
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 1, b: 9};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 4; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid import pk::*; #(parameter c_t P = C) (output logic o);
  localparam in_t S = P.u;
  assign o = 1'b0;
endmodule
module dut(output logic o);
  kid k0 (.o(o));
endmodule
