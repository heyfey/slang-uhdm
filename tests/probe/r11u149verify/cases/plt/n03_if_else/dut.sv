// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed { logic v; logic [3:0] sat; } e_t;
endpackage
module dut(input logic clk, input logic c, input logic r, input logic [1:0] i, output p::e_t [1:0] tbl);
  always_ff @(posedge clk)
    if (c) tbl[r].sat[i] <= 1'b1;
    else tbl[r].sat[i] <= 1'b0;
endmodule
