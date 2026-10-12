// § modFnLitLeftoverAtLiteral302
// vl08: a $unit builder called from two modules, the literal shared
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
function automatic pk::c_t mk();
  pk::c_t c; c.a = 8; c.b = 80; return c;
endfunction
module m1(output logic o);
  localparam pk::c_t L = mk();
  assign o = L.a[0];
endmodule
module m2(output logic o);
  localparam pk::c_t L = mk();
  assign o = L.b[0];
endmodule
module dut(output logic o1, o2);
  m1 u1 (.o(o1));
  m2 u2 (.o(o2));
endmodule
