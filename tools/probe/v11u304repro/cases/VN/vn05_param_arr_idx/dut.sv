// § hpOpIdxNestedSelByPath304
module top (output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  localparam int P[2] = '{1, 2};
  el_t [3:0] ea;
  always_comb o = ea[P[0] + 1].fld;
endmodule
