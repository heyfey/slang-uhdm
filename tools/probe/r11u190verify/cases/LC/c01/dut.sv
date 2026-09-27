// § procLvIdxCallWholeSpan181 § lvSelIdxChainName181 § classMethodLvIsProcess181 (r11u190: the call in a procedural lvalue's index is itself a MEMBER call)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  class O;
    function int get(); return 1; endfunction
  endclass
  class H;
    int arr [4];
    O o;
    function int idx(); return 2; endfunction
    function void g();
      arr[o.get()] = 1;
      arr[this.idx()] = 2;
    endfunction
  endclass
  O o;
  m_t m;
  int arr [4];
  initial begin
    o = new;
    arr[o.get()] = 3;
    m.w[o.get()].v = 4;
  end
endmodule
