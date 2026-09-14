// b3: NAMED arguments, a REORDERED call, and a member written from a formal
// that is NOT in declaration position -- which formal's typespec is stamped.
package pk;
  typedef struct packed { int unsigned p; int unsigned q; } cfg_t;
  function automatic cfg_t mk(int unsigned first, logic [15:0] second);
    cfg_t c;
    c.p = second;   // member 0 <- formal 1
    c.q = first;    // member 1 <- formal 0
    return c;
  endfunction
  localparam cfg_t CFG = mk(.second(16'h00F0), .first(9));
endpackage
module dut(output logic o);
  assign o = ^{pk::CFG.p[0], pk::CFG.q[0]};
endmodule
