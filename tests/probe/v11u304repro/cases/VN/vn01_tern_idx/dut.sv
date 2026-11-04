// § hpOpIdxTernTrueKeepsIdxLoc304v
module top (input logic c, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  always_comb o = ea[c ? k[0] : k[1]].fld;
endmodule
