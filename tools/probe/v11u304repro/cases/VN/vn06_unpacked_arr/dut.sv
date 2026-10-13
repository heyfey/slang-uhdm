// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k [2], output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t ea [4];
  always_comb o = ea[k[0] + 2'd1].fld;
endmodule
