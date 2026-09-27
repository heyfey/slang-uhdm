// § memberSelParenIdxSpan184: a member path's parenthesized select index spans the parentheses (rvalue)
typedef struct packed { logic [7:0] f; logic [3:0][1:0] g; } s_t;
module top;
  s_t s;
  s_t arr [4];
  logic y, z, w;
  logic [1:0] v;
  int i;
  initial begin
    y = s.f[(i)];
    z = s.f[((i + 1))];
    v = s.g[(i)];
    w = arr[(i)].f[(i*2)];
  end
endmodule
