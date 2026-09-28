package p;
  class C #(type T = int);
    T v;
  endclass
  typedef C #(byte) c_t;
  function automatic c_t mk();
    return null;
  endfunction
endpackage
module t06; endmodule
