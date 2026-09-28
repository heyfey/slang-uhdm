package p;
  class C #(type T = int);
    T v;
  endclass
  class D;
    typedef C #(shortint) lc_t;
    lc_t h;
    function lc_t get();
      return h;
    endfunction
  endclass
endpackage
module t04; endmodule
