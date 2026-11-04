// § caAnySysCallLhsTs428
typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t;
module top(input s_t s, output [2:0] y);
  assign y = $countones(s.f);
endmodule
