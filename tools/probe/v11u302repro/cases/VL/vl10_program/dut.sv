// § modFnLitLeftoverAtLiteral302
// vl10: the builder in a program block and in an interface body, with an implicit net beside
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
interface ifc;
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 2; c.b = 20; return c;
  endfunction
  localparam pk::c_t L = mk();
  logic s;
endinterface
program prg;
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 4; c.b = 40; return c;
  endfunction
  localparam pk::c_t L = mk();
endprogram
module dut(output logic o);
  ifc i0 ();
  prg p0 ();
  assign w = i0.s;
  assign o = w;
endmodule
