// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  logic [3:0] m [2];
  always_comb o = ea[m[k[0]][1] + 1].fld;
endmodule
