// § aliasFormalCopyPerClone478 (control: a direct enum typedef, not an alias of an alias)
package h;
  typedef enum {A, B} mode_e;
  class C;
    extern function void set(mode_e val);
  endclass
  function void C::set(mode_e val);
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
