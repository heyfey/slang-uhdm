// § leftoverSlotSoleWriter302v
// vq03: an explicit import pk::UU plus a qualified read in one builder and an unqualified read in another
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage
module dut(output logic o);
  import pk::UU;
  function automatic pk::c_t mk();
    pk::c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  function automatic pk::c_t mk2();
    pk::c_t c; c.u = UU; c.d = 65; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::c_t L2 = mk2();
  localparam pk::in_t MS = L.u;
  assign o = 1'b0;
endmodule
