// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, j, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld;} in_t;
  typedef struct packed {in_t [3:0] arr;} el_t;
  el_t [3:0] ea;
  always_comb o = ea[k[0] + 1].arr[j[1] + 1].fld;
endmodule
