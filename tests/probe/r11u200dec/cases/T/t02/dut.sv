package p;
  class C #(type T = int);
    T v;
  endclass
  class E;
  endclass
  typedef C #(E) c_t;
  class D;
    extern function c_t get();
  endclass
  function c_t D::get();
    return null;
  endfunction
endpackage
module t02; endmodule
