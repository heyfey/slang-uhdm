// § modFnLitLeftoverAtLiteral302
// l09: two localparams from one module builder, an argument and a literal
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input int unsigned x);
    pk::c_t c; c.a = x; c.b = 16; return c;
  endfunction
  localparam pk::c_t L1 = mk(3);
  localparam pk::c_t L2 = mk(5);
  localparam int unsigned S = L1.b + L2.a;
  assign o = 1'b0;
endmodule
