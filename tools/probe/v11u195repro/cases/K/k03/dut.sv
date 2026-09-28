// § procNetMidSelDotted195 — v11u195 fresh: a generate-local net read with a mid select inside the generate block's process, one and two levels down, and a unary/call index
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t r, input logic [1:0] i, output logic [3:0] o [2], output logic [3:0] o2 [2][2]);
  function automatic logic [1:0] nx(input logic [1:0] a); return a + 1; endfunction
  for (genvar g = 0; g < 2; g++) begin : gl
    wire rp::reg2hw_t n = r;
    always_comb o[g] = n.key[~i].q;
    for (genvar h = 0; h < 2; h++) begin : gh
      always_comb o2[g][h] = n.key[nx(i)].q ^ r.key[h].q;
    end
  end
endmodule
