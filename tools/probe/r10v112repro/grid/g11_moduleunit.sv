// g11 — the same specializations OUTSIDE a class: three module-scope typedefs
// of one foreign generic, with different arguments.  A module-scope typedef is
// not class-nested, so pass 54's group must not collect it and the overwrite
// must not reach it.  Golden is the arbiter of whether it clones there too.
package p11box;
  class B11 #(type Q = int, string Nm = "?"); int x11; endclass
endpackage
package p11use;
  class Za11; int z11; endclass
  class ab11; int a11; endclass
endpackage
module g11top;
  import p11box::*;
  import p11use::*;
  typedef B11 #(Za11,"Za11") mod_id11;
  typedef B11 #(ab11,"ab11") mod2_id11;
  mod_id11  m11;
  mod2_id11 n11;
endmodule
