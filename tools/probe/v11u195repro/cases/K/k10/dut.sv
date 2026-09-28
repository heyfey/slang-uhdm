// § procNetMidSelDotted195 — v11u195 fresh: the path nested two levels in plain array indices, and a unary and a call index on the mid select
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, input logic [1:0] i, output logic [3:0] o, output logic [3:0] o2);
  function automatic logic [1:0] nx(input logic [1:0] a); return a + 1; endfunction
  logic [3:0] tab [16];
  logic [3:0] idx [16];
  always_comb o = tab[idx[reg2hw.key[i].q]];
  always_comb o2 = reg2hw.key[~i].q & reg2hw.key[nx(i)].q;
endmodule
