// § hpOpIdxNestedSelByPath304
module top (input logic [3:0] v, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  always_comb o = ea[v[0] + 1'b1].g;
endmodule
