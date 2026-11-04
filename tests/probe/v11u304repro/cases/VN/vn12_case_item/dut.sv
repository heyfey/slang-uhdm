// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, input logic [7:0] s, output logic o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  always_comb case (s)
    ea[k[0] + 1].fld: o = 1'b1;
    default: o = 1'b0;
  endcase
endmodule
