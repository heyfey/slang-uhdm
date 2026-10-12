// § modPatLeftoverCloneNoParent302
// vp06: the module's own UU shadows a wildcard-imported package UU of the same type
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 1, b: 2};
endpackage
module dut import pk::*; (output logic o);
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t L = mk();
  localparam in_t MS = L.u;
  assign o = 1'b0;
endmodule
