// § rootTdLeftoverStamp302
// r04: a package typedef with the same name and members as the $root one
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } rc_t;
  function automatic rc_t mk();
    rc_t c; c.a = 1; c.b = 2; return c;
  endfunction
  localparam rc_t P = mk();
endpackage
module dut(output logic o);
  function automatic rc_t mk2();
    rc_t c; c.a = 7; c.b = 8; return c;
  endfunction
  localparam rc_t L = mk2();
  localparam int unsigned S = L.a + pk::P.b;
  assign o = S[0];
endmodule
