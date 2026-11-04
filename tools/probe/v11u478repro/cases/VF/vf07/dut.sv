// § aliasFormalCopyPerClone478 (a provider chain: t reaches h only through a)
package h;
  typedef enum {A, B} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package a;
  import h::*;
  class X; function int g(); return f(A); endfunction endclass
endpackage
package t;
  import a::*;
  class T; X x; endclass
endpackage
package s;
  import h::*;
  class Y; function int g(); return f(B); endfunction endclass
endpackage
module top;
  import t::*; import s::*;
  T o; Y y;
endmodule
