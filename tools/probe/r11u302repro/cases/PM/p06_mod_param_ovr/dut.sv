// § modPatLeftoverCloneNoParent302
// p06: the pattern is a header parameter, overridden on one instance
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage
module kid #(parameter pk::in_t UU = '{a: 1, b: 2}) (output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.d = 9; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  assign o = 1'b0;
endmodule
module dut(output logic o, output logic q);
  kid k0 (.o(o));
  kid #(.UU('{a: 7, b: 8})) k1 (.o(q));
endmodule
