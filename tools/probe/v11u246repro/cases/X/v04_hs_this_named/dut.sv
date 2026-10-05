// § hpFnStaticTrailScopeJoin246
package p;
  virtual class base;
    pure virtual function int hook(int a, int b = 2);
  endclass
  class c extends base;
    int arr[4];
    extern function int user();
    function void st();
      static int idx;
      idx++;
    endfunction
    virtual function int hook(int a, int b = 2); return a + b; endfunction
  endclass
  function int c::user();
    int r;
    r = this.hook(.a(st.idx));
    r += hook(st.idx, );
    r += this.arr[st.idx];
    return r + later(.x(st.idx));
  endfunction
  function int later(int x, int y = 1); return x + y; endfunction
endpackage
module top;
endmodule
