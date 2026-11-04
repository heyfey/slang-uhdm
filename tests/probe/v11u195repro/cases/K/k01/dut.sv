// § procNetMidSelDotted195 — v11u195 fresh: a net-based mid select as a function-call argument, in $display, and in an event control
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, input logic [1:0] i, output logic [3:0] o, output logic p);
  function automatic logic [3:0] inv(input logic [3:0] a); return ~a; endfunction
  always_comb o = inv(reg2hw.key[i].q);
  always @(posedge reg2hw.key[1].qe) p <= reg2hw.key[2].qe;
  initial $display("%b", reg2hw.key[i].q);
endmodule
