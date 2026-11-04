// § aliasFormalCopyPerClone478 (the base enum declared in another package)
package e;
  typedef enum {A, B} mode_e;
endpackage
package h;
  import e::*;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package i0;
  import e::*; import h::*;
  class X0; function int g(); return f(A); endfunction endclass
endpackage
package i1;
  import e::*; import h::*;
  class X1; function int g(); return f(B); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
