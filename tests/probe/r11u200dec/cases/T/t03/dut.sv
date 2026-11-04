package p;
  class C #(type T = int);
    T v;
  endclass
  typedef C c_t;
  class D;
    function c_t get();
      return null;
    endfunction
  endclass
endpackage
module t03; endmodule
