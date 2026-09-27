// § incDecBitSelWholeSpan181 — a packed bit and a two-dimensional element as inc/dec operands, and a member path (control)
module top(input int i);
  int m2 [4][4];
  typedef struct { int a [4]; } s_t;
  s_t s;
  initial begin
    m2[i][i+1]++;
    s.a[i]++;
  end
endmodule
