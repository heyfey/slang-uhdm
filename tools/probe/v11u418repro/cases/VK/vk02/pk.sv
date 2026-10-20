// § tdKeptParentMemberNames418
module top; endmodule
package tp;
  typedef struct packed { logic clk; logic op; } in_s;
  typedef struct packed { in_s i; logic [1:0] v; } outer_s;
endpackage
