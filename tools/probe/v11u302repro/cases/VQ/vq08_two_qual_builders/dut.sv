// § leftoverSlotSoleWriter302v
// vq08: two modules each with a builder: one reads pk::UU qualified, the other reads its own module pattern
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage
module m1 import pk::*; (output logic o);
  function automatic c_t mk();
    c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  localparam c_t L = mk();
  assign o = L.u.a[0];
endmodule
module dut(output logic o, o1);
  localparam pk::in_t VV = '{a: 33, b: 44};
  function automatic pk::c_t mk();
    pk::c_t c; c.u = VV; c.d = 65; return c;
  endfunction
  localparam pk::c_t L = mk();
  m1 u1 (.o(o1));
  assign o = L.u.a[0];
endmodule
