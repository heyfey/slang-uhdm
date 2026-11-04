// § hpBaseSelMidMemberBare133
// case hm03: middle member path as an if condition in always_ff
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
module dut(input logic clk, input logic [1:0] r, input logic [15:0] flat, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  always_ff @(posedge clk) begin
    if (tbl[r].f.valid) o <= 1'b1;
    else o <= 1'b0;
  end
endmodule
