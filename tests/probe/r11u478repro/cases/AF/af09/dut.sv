// § aliasFormalCopyPerClone478 (two importers, each cloning two subroutines with the alias formal)
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
package a;
  import h::*;
  class X; C c; endclass
endpackage
package s;
  import h::*;
  class Z; C c; endclass
endpackage
module top;
  import a::*;
  import s::*;
  X x; Z z;
endmodule
