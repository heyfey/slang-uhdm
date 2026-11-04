// § aliasFormalCopyPerClone478 (control: alias of an alias of a struct)
package h;
  typedef struct {int a; int b;} st_t;
  typedef st_t S1;
  typedef S1 M_T;
  typedef enum {A, B} e_t;
  function automatic int f(M_T v);
    return v.a;
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); M_T s; return f(s); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); M_T s; return f(s); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
