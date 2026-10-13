// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k [2], output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  typedef enum int {Z0, Z1} e_t;
  el_t [3:0] ea;
  always_comb o = ea[k[Z1] + Z1].fld;
endmodule
