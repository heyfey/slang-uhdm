// § incDecBitSelWholeSpan181 § incDecMixedPathIsLvalue181 (v11u181 break: inc/dec inside an index, a condition and a call argument)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  int cnt [0:3];
  m_t m;
  int i, y;
  initial begin
    y = cnt[cnt[i]++];
    if (m.w[i].v++ > 2) y = 1;
    $display(cnt[i]--, m.w[i+1].v++);
  end
endmodule
