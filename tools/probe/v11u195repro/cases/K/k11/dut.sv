// § procNetMidSelDotted195 — v11u195 fresh: a procedural force on the input port's mid select and an initial display
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, input logic [1:0] i, output logic [3:0] o);
  initial begin
    force reg2hw.key[1].q = 4'h3;
    $display("%b", reg2hw.key[i].q);
  end
  assign o = reg2hw.key[1].q;
endmodule
