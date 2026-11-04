package p;
  class C #(type T = int);
    T v;
  endclass
  typedef C #(byte) c_t;
  class D;
    c_t h;
    function c_t get();
      return h;
    endfunction
  endclass
endpackage
module t01; endmodule
