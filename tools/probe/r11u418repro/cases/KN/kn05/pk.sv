// § tdKeptParentMemberNames418
module top; m u (.ti(3'b0), .o()); endmodule
package tp;
  typedef struct packed { logic clk; logic op; logic param; } tag_s;
endpackage
package dp;
  import tp::*;
  typedef struct packed { tag_s a; } l_s;
endpackage
