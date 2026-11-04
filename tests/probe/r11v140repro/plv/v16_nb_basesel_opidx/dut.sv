// § procLvBaseSelTrailAtIdx140
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
endpackage
module dut(input logic clk, input logic [1:0] r, input logic [1:0] i, output logic [9:0] q);
  p::e_t [1:0] tbl;
  always_ff @(posedge clk) tbl[r].sat[i ^ 2'd1] <= 1'b1;
  assign q = tbl;
endmodule
