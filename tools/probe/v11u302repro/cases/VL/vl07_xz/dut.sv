// § modFnLitLeftoverAtLiteral302
// vl07: unbased x and z and an all-ones literal on the members
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; logic [3:0] d; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 'x; c.b = '1; c.d = 4'bz01x; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam logic [3:0] LB = L.b;
  assign o = 1'b0;
endmodule
