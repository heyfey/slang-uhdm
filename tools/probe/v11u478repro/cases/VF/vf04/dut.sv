// § aliasFormalCopyPerClone478 (a module importer beside a package importer)
package h;
  typedef enum {A, B} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); return f(A); endfunction endclass
endpackage
module top;
  import h::*;
  import i0::*;
  X0 x0;
  int r;
  initial r = f(B);
endmodule
