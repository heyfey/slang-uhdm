// § aliasFormalCopyPerClone478 (two alias formals in two functions, two importers)
package h;
  typedef enum {A, B} mode_e;
  typedef enum {P, Q} kind_e;
  typedef mode_e M_T;
  typedef kind_e K_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
  function automatic int k(K_T w);
    return int'(w);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); return f(A) + k(P); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); return f(B) + k(Q); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
