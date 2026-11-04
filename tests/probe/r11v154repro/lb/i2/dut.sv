// § lvPathBaseAtFirstMember154
module top(input logic [3:0] x);
  typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t;
  s_t sv;
  assign sv.wdtxx[3:0] = x;
endmodule
