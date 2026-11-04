// § aliasFormalCopyPerClone478 (class method and free function sharing the alias, two importers)
package h;
  typedef enum {A, B} mode_e;
  typedef mode_e M_T;
  function automatic int pf(M_T v);
    return int'(v);
  endfunction
  class C;
    extern function void set(M_T val);
  endclass
  function void C::set(M_T val);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; C c; function int g(); return pf(A); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; C c; function int g(); return pf(B); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
