// § cloneTdSpecDeepCopy269
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    T m;
  endclass
  class cmp #(type B = int) extends comp;
    typedef cmp #(B) this_type;
    typedef reg_c #(this_type) type_id;
  endclass
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(sbase, "sbase") type_id;
  endclass
endpackage
module top;

  sp::sbase s;
endmodule
