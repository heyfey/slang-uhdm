// b5: TWO formals, both members a WHOLE FORMAL READ, literal actuals.
// Formal kinds: `int unsigned` (unsized decimal actual) and `logic [7:0]`
// (sized hex actual).
package pk;
  typedef struct packed { int unsigned a; logic [7:0] b; } cfg_t;
  function automatic cfg_t mk(int unsigned xa, logic [7:0] xb);
    cfg_t c; c.a = xa; c.b = xb; return c;
  endfunction
  localparam cfg_t CFG = mk(64, 8'hAB);
endpackage
module dut(output logic o);
  assign o = ^{pk::CFG.a[0], pk::CFG.b[0]};
endmodule
