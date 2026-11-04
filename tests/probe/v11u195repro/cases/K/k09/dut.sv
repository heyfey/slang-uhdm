// § procNetMidSelDotted195 — v11u195 fresh: processes in one- and two-level for-generates reading the port with a genvar and a variable index
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, input logic [1:0] i, output logic [3:0] o [2], output logic [3:0] o2 [2][2]);
  for (genvar g = 0; g < 2; g++) begin : gl
    always_comb o[g] = reg2hw.key[g].q ^ reg2hw.key[i].q;
    for (genvar h = 0; h < 2; h++) begin : gh
      always_comb o2[g][h] = reg2hw.key[h+g].q;
    end
  end
endmodule
