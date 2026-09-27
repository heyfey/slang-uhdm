// § incDecMixedPathIsLvalue181 § incDecMemberSelIsLvalue184 § incDecSelTopRestore184v § incDecBitSelWholeSpan181 (r11u190 cross: pass 184's member-select operands (a class handle's array member, a struct member array) beside pass 181's mixed paths, in a class task and a module initial, pre and post, statement and read forms)
module top;
  typedef struct { int arr [4]; } s_t;
  typedef struct { s_t w [4]; } m_t;
  class H;
    int h_arr [4];
    s_t st;
    m_t mm;
    task t(int s, int k);
      int r;
      h_arr[s]++;
      this.h_arr[s]--;
      st.arr[s]++;
      ++mm.w[k].arr[s];
      r = st.arr[s]++;
    endtask
  endclass
  H hnd;
  s_t sv;
  m_t m;
  int s, k, r;
  initial begin
    hnd = new;
    hnd.h_arr[s]++;
    --hnd.h_arr[s + 1];
    sv.arr[s]++;
    m.w[k].arr[s]--;
    r = hnd.h_arr[s]++;
  end
endmodule
