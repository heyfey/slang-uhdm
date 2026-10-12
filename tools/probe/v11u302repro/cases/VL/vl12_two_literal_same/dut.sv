// § modFnLitLeftoverAtLiteral302
// vl12: the same member written twice with literals, then a member written from the argument
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input int unsigned x);
    pk::c_t c; c.b = 11; c.b = 12; c.a = x; return c;
  endfunction
  localparam pk::c_t L = mk(9);
  localparam int unsigned LB = L.b;
  assign o = 1'b0;
endmodule
