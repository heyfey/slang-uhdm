// § incDecMemberSelIsLvalue184: inc/dec operands that are member paths ending in an element select
typedef struct packed { logic [7:0] f; logic [3:0][1:0] g; } s_t;
typedef struct packed { s_t a; logic [3:0] h; } n_t;
module top;
  s_t s;
  n_t n;
  int i, k;
  initial begin
    s.f[i]++;
    s.f[(i)]++;
    --s.g[k];
    ++n.a.f[i + 1];
    n.h[2]--;
  end
endmodule
