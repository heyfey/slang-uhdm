// § aliasFormalCopyPerClone478
package h;
  typedef enum {A, B, C2} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package a;
  import h::*;
  class X; function int g(); return f(A); endfunction endclass
endpackage
package b;
  import h::*;
  class Y; function int g(); return f(B); endfunction endclass
endpackage
module top;
  import a::*;
  import b::*;
  X x; Y y;
endmodule
