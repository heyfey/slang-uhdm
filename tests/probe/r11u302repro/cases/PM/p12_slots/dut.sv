// § modPatLeftoverCloneNoParent302
// p12: the result's members in constant slots
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage
module dut(input logic [31:0] i, output logic [7:0] o);
  localparam pk::in_t UU = '{a: 8, b: 2};
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.d = 4; return c;
  endfunction
  localparam pk::c_t L = mk();
  logic [L.u.a-1:0] w;
  assign w = i[L.u.a-1:0];
  assign o = {L.u.b{w[3:0]}};
endmodule
