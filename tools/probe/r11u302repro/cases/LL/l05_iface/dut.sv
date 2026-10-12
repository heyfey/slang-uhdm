// § modFnLitLeftoverAtLiteral302
// l05: an interface holds the builder and the localparam
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
interface ifc;
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 3; c.b = 4; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam int unsigned LB = L.b;
  logic s;
endinterface
module dut(output logic o);
  ifc u();
  assign o = u.s;
endmodule
