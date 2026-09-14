// b6: the OTHER formal kinds -- `bit`, `byte` -- with matching actuals.
package pk;
  typedef struct packed { bit a; byte b; } cfg_t;
  function automatic cfg_t mk(bit xa, byte xb);
    cfg_t c; c.a = xa; c.b = xb; return c;
  endfunction
  localparam cfg_t CFG = mk(1'b1, 8'd5);
endpackage
module dut(output logic o);
  assign o = ^{pk::CFG.a, pk::CFG.b[0]};
endmodule
