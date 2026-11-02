// § importEnumCloneHomeInst469
// downstream: an enum state machine whose reset state is an imported package parameter
package a;
  typedef enum logic [1:0] {IDLE, RUN, DONE} st_t;
  parameter st_t RST = IDLE;
endpackage
package b;
  import a::*;
endpackage
module top(input logic clk, input logic rst, output logic [1:0] q);
  import a::*;
  st_t s;
  always_ff @(posedge clk) if (rst) s <= RST; else s <= (s == RUN) ? DONE : RUN;
  assign q = s;
endmodule
