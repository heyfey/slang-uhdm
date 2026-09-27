// § incDecMixedPathIsLvalue181 § incDecBitSelWholeSpan181 § classMethodLvIsProcess181 § lvSelIdxChainName181 (r11u190: a member path through TWO selects, this and super paths, in a class TASK)
class B;
  int arr [4];
endclass
class D extends B;
  typedef struct { int v; } s_t;
  typedef struct { s_t x [2]; } w_t;
  typedef struct { w_t w [2]; } m_t;
  m_t m;
  task t(int i, int j);
    m.w[i].x[j].v++;
    ++m.w[i].x[j].v;
    this.arr[i]++;
    super.arr[j]--;
    this.m.w[i].x[j].v--;
  endtask
endclass
module top;
  initial begin
    D d = new;
    d.t(0, 1);
  end
endmodule
