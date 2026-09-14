// b9: b5's MODULE-holder twin -- the same two-formal function, the assembled
// localparam held by the module.
package pk;
  typedef struct packed { int unsigned a; logic [7:0] b; } cfg_t;
  function automatic cfg_t mk(int unsigned xa, logic [7:0] xb);
    cfg_t c; c.a = xa; c.b = xb; return c;
  endfunction
endpackage
module dut(output logic o);
  localparam pk::cfg_t CFG = pk::mk(64, 8'hAB);
  assign o = ^{CFG.a[0], CFG.b[0]};
endmodule
