// § aliasFormalCopyPerClone478 (an alias formal with a default)
package h;
  typedef enum {A, B} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v = B);
    return int'(v);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); return f(); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); return f(A); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
