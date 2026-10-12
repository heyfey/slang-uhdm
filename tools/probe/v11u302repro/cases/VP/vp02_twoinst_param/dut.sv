// § modPatLeftoverCloneNoParent302
// vp02: a module pattern PARAMETER overridden differently on two instances, read by the builder
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage
module kid #(parameter pk::in_t UU = '{a: 1, b: 2}) (output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam pk::c_t L = mk();
  assign o = L.u.a[0];
endmodule
module dut(output logic o1, o2);
  kid #(.UU('{a: 5, b: 6})) u1 (.o(o1));
  kid #(.UU('{a: 7, b: 8})) u2 (.o(o2));
endmodule
