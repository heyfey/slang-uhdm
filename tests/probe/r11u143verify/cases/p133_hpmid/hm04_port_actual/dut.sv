// § hpBaseSelMidMemberBare133
// case hm04: middle member path as a port connection actual
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
module sink(input logic i, output logic o); assign o = ~i; endmodule
module dut(input logic [1:0] r, input logic [15:0] flat, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  sink s(.i(tbl[r].f.valid), .o(o));
endmodule
