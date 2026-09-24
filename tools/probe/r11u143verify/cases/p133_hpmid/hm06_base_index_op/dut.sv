// § hpBaseSelMidMemberBare133
// case hm06: the base select's index is an operation
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
module dut(input logic r, input logic [15:0] flat, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r + 1'b0].f.valid;
endmodule
