// § hpOpIdxNestedSelByPath304
module top (input logic [3:0] w, input logic [1:0] j, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld;} el_t;
  el_t [3:0] ea;
  logic [1:0] k;
  logic [7:0] x;
  always_comb o = {7'b0, x[ea[k[0] + 1].fld[2:0]]};
endmodule
