// § tdKeptParentMemberNames418
module top; endmodule
package tp;
  typedef union packed { logic [2:0] clk; logic [2:0] op; } tag_s;
endpackage
package dp;
  import tp::*;
  typedef struct packed { tag_s a; } l_s;
endpackage
