// § hpOpIdxNestedSelByPath304
module top (input logic [3:0] k, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  always_comb o = ea[k[1:0] + 2'd1].fld;
endmodule
