// § tdKeptParentMemberNames418
module top; endmodule
package tp;
  parameter W = 3;
  typedef struct packed { logic [W-1:0] clk; logic op; } tag_s;
endpackage
