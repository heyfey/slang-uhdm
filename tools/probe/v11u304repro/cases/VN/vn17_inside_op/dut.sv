// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, output logic o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  always_comb o = ea[k[0] + 1].fld inside {8'h1, 8'h2};
endmodule
