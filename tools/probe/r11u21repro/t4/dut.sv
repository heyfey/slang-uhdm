// t4 — the read held by a PACKAGE localparam, and by a WILDCARD-IMPORTED copy.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mk();
    c_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam c_t C  = mk();
  localparam int PA = C.a;          // read INSIDE the package
  localparam int PB = C.b * 2;      // tainted operation inside the package
endpackage

module dut(output logic o);
  import pk::*;
  localparam int MA = C.a;          // read through the wildcard import
  localparam int MB = pk::C.b;      // read written QUALIFIED
  assign o = ^{PA[0], PB[0], MA[0], MB[0]};
endmodule
