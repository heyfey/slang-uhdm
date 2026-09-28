// § procNetMidSelDotted195 — v11u195 fresh: an inc/dec of a plain array indexed by the path, and the path in a call-argument index
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input logic clk, input rp::reg2hw_t reg2hw, input logic [1:0] i, output logic [3:0] o);
  logic [3:0] cnt [16];
  function automatic logic [3:0] pick(input logic [3:0] a); return a; endfunction
  always_ff @(posedge clk) begin
    cnt[reg2hw.key[i].q]++;
    o <= cnt[pick(reg2hw.key[i].q)];
  end
endmodule
