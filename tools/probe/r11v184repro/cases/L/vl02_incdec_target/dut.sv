// § lvIdxMemberSelIsRead184 § incDecMemberSelIsLvalue184: an inc/dec whose operand is a plain select indexed by a member select, and a member-select inc/dec indexed by a member select
typedef struct packed { logic [3:0] f; } s_t;
typedef struct packed { logic [15:0] g; } t_t;
module top;
  s_t s;
  t_t s2;
  int cnt [16];
  int i;
  initial begin
    cnt[s.f[i]]++;
    s2.g[s.f[i]]++;
    --cnt[s.f[i + 1]];
  end
endmodule
