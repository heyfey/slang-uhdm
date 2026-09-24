// § hpBaseSelMidMemberBare133
// case hm02: a two-dimensional base select before the middle member
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
module dut(input logic r, input logic c, input logic [31:0] flat, output logic o);
  p::w_t [1:0][1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r][c].f.valid;
endmodule
