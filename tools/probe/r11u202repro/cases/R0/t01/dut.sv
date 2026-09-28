// § classTdRetSharesTypedefTs200
package p;
  class B #(int N = 1);
    int v = N;
  endclass
  typedef B #(4) b4_t;
  class H;
    b4_t m;
    extern function b4_t get();
  endclass
  function b4_t H::get();
    return m;
  endfunction
endpackage
module t01; endmodule
