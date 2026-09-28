// § procNetMidSelDotted195 — v11u195 fresh: an unpacked array of struct nets selected then a mid select (two selects on the path), and the path nested two levels in plain array indices
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t r, input logic [1:0] i, output logic [3:0] o, output logic [3:0] o3);
  wire rp::reg2hw_t arr [2];
  assign arr[0] = r;
  assign arr[1] = r;
  logic [3:0] tab [16];
  logic [3:0] idx [16];
  always_comb o = arr[1].key[i].q;
  always_comb o3 = tab[idx[r.key[i].q]];
endmodule
