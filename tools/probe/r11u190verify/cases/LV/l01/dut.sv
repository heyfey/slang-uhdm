// § classMethodLvIsProcess181 § lvSelIdxChainName181 (r11u190: a STATIC class method writing a static member path through selects)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  class C;
    static m_t st;
    static function void s(int j);
      st.w[j].v = 1;
      st.w[j + 1].v += 2;
    endfunction
  endclass
  initial C::s(1);
endmodule
