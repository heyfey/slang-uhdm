// § paramInitMemberSelFoldBaseSpan294
// a module-local struct parameter assembled by a module function
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; logic [7:0] m; } c_t;
  localparam c_t C = '{u: '{a: 1, b: 2}, d: 5, m: 8'h21};
  function automatic c_t mk();
    c_t c; c.u.a = 3; c.u.b = 32; c.d = 64; c.m = 8'h5A; return c;
  endfunction
  localparam c_t F = mk();
endpackage
module dut(output logic [7:0] o);
  function automatic pk::c_t mk2(); pk::c_t c; c.u.a = 1; c.u.b = 2; c.d = 3; c.m = 8'h4; return c; endfunction
  localparam pk::c_t L = mk2();
  localparam logic B = L.d[2];
  assign o = B;
endmodule
