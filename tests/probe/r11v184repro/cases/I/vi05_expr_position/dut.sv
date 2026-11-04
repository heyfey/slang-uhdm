// § incDecMemberSelIsLvalue184: a member-select increment in expression position and in a condition
typedef struct packed { logic [7:0] f; } s_t;
module top;
  s_t s;
  int k, x;
  initial begin
    x = s.f[k]++;
    if (s.f[k + 1]--) x = 1;
  end
endmodule
