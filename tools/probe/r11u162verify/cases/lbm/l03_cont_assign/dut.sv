// § lvPathBaseAtFirstMember154
module top(input logic [3:0] x, output logic [15:0] o);
  typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t;
  s_t sv;
  assign sv.wdtxx[3:0] = x;
  assign o = sv;
endmodule
