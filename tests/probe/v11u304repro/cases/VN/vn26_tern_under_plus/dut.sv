// § hpOpIdxTernTrueKeepsIdxLoc304v
module top (input logic c, d, input logic [1:0] j, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  logic [1:0] k [4];
  logic [1:0] m [2];
  always_comb o = ea[(c ? k[0] : k[1]) + 2'd1].fld;
endmodule
