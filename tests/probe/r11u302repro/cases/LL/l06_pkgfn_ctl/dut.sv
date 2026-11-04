// § modFnLitLeftoverAtLiteral302
// l06: CONTROL - a package builder (the body object is emitted; the law stays out)
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mk();
    c_t c; c.a = 5; c.b = 64; return c;
  endfunction
endpackage
module dut(output logic o);
  localparam pk::c_t L = pk::mk();
  localparam int unsigned LA = L.a;
  assign o = 1'b0;
endmodule
