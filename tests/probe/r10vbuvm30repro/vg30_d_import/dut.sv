package pv30d;
  class cv30d;
    int m;
    extern function int d_cmp();
    extern function int d_concat();
  endclass
  function int cv30d::d_cmp();    return (m == -1);  endfunction
  function int cv30d::d_concat(); return {-1, 1};    endfunction
endpackage

module mv30d;
  import pv30d::*;
  cv30d h;
  int x;
  initial x = h.d_cmp();
endmodule

module mv30d_top;
  mv30d i0();
  mv30d i1();
  mv30d i2();
endmodule
