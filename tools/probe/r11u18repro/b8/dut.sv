// b8: the actual is an EXPRESSION and a nested CALL -- neither is an object the
// producer can hand back.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } cfg_t;
  localparam int unsigned PK = 7;
  function automatic int unsigned dbl(int unsigned v); return v * 2; endfunction
  function automatic cfg_t mk(int unsigned xa, int unsigned xb);
    cfg_t c; c.a = xa; c.b = xb; return c;
  endfunction
  localparam cfg_t CFG = mk(PK + 1, dbl(3));
endpackage
module dut(output logic o);
  assign o = ^{pk::CFG.a[0], pk::CFG.b[0]};
endmodule
