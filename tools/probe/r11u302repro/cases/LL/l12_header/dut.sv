// § modFnLitLeftoverAtLiteral302
// l12: a header parameter initialised by the module builder, overridden by one instance
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module kid #(parameter pk::c_t P = '{a: 1, b: 2}) (output logic o);
  assign o = P.a[0];
endmodule
module dut(output logic o, output logic q);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 6; c.b = 8; return c;
  endfunction
  localparam pk::c_t L = mk();
  kid #(.P(L)) k0 (.o(o));
  kid k1 (.o(q));
endmodule
