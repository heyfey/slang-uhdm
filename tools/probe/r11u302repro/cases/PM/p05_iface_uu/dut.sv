// § modPatLeftoverCloneNoParent302
// p05: the pattern localparam and the builder in an interface
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage
interface ifc;
  localparam pk::in_t UU = '{a: 3, b: 4};
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.d = 5; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  logic s;
endinterface
module dut(output logic o);
  ifc u();
  assign o = u.s;
endmodule
