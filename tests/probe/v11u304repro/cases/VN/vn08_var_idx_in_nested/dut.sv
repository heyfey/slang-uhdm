// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k [4], input logic [1:0] j, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  always_comb o = ea[k[j] - 1].fld;
endmodule
