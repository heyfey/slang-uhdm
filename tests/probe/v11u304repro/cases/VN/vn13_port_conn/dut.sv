// § hpOpIdxNestedSelByPath304
module c (input logic [7:0] i, output logic [7:0] o); assign o = i; endmodule
module top (input logic [1:0] k, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  c u (.i(ea[k[0] + 1].fld), .o(o));
endmodule
