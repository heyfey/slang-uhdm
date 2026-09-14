// b7: the actual is a WHOLE PARAMETER READ -- does the leftover carry the
// FORMAL's typespec or the parameter's own object/typespec?
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } cfg_t;
  localparam int unsigned PK = 7;
  localparam logic [7:0]  PL = 8'hAB;
  function automatic cfg_t mk(int unsigned xa, int unsigned xb);
    cfg_t c; c.a = xa; c.b = xb; return c;
  endfunction
  localparam cfg_t CFG = mk(PK, PL);
endpackage
module dut(output logic o);
  assign o = ^{pk::CFG.a[0], pk::CFG.b[0]};
endmodule
