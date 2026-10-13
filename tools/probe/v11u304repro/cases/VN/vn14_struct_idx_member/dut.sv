// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  typedef struct packed {logic [1:0] i;} h_t;
  h_t [1:0] hs;
  el_t [3:0] ea;
  always_comb o = ea[hs[k[0]].i + 1].fld;
endmodule
