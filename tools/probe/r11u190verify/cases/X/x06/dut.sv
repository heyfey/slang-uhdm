// § incDecMixedPathIsLvalue181 § incDecMemberSelIsLvalue184 § incDecSelTopRestore184v § incDecBitSelWholeSpan181 (r11u190 cross: the same inc/dec operands through member selects and bit selects, pre and post, read and statement forms)
module top;
  typedef struct { int v; int arr [4]; } s_t;
  typedef struct { s_t w [4]; } m_t;
  m_t m;
  int k, r;
  initial begin
    m.w[k].v++;
    --m.w[k].v;
    m.w[k].arr[k + 1]++;
    r = m.w[k].v++;
    r = --m.w[k + 1].arr[k];
  end
endmodule
