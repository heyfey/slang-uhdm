package p;
  class C #(type T = int);
    T v;
  endclass
  typedef C #(byte) c_t;
endpackage
module t05;
  function p::c_t get();
    return null;
  endfunction
endmodule
