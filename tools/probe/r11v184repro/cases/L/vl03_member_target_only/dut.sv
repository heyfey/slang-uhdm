// § lvIdxMemberSelIsRead184: a member-select read nested in a member-path target's index and in a two-index target
typedef struct packed { logic [3:0] f; } s_t;
module top (input logic clk);
  s_t s;
  logic [3:0] m2 [4][4];
  int i, j;
  always_ff @(posedge clk) m2[s.f[i]][s.f[j]] <= 4'd1;
endmodule
