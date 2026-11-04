// § aliasFormalCopyPerClone478
package h;
  typedef enum {A, B} mode_e;
  typedef mode_e M_T;
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
package t;
  import a::*;
  class Y; X x; endclass
endpackage
package s;
  import h::*;
  import a::*;
  import t::*;
  class Z; Y y; endclass
endpackage
module top;
  import s::*;
  Z z;
endmodule
