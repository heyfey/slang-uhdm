// § classMethodLvIsProcess181 § lvSelIdxChainName181 (r11u190: a method of a PARAMETERIZED class, specialized in a module)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  class C #(int N = 4);
    m_t q;
    function void g(int j);
      q.w[j].v = N;
      q.w[j % N].v = 0;
    endfunction
  endclass
  initial begin
    C #(2) c = new;
    c.g(1);
  end
endmodule
