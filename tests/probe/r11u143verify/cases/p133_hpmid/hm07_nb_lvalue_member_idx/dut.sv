// § hpBaseSelMidMemberBare133
// case hm07: a middle-member path as a nonblocking lvalue with a trailing select
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
module dut(input logic clk, input logic [1:0] r, input logic [1:0] i, output logic [15:0] flat);
  p::w_t [1:0] tbl;
  always_ff @(posedge clk) tbl[r].f.sat[i] <= 1'b1;
  assign flat = tbl;
endmodule
