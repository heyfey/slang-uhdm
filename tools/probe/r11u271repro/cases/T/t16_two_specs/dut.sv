// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    T m;
    function T g();
      T o;
      return o;
    endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(sbase, "sbase") type_id;
  endclass
  class s2 extends comp;
    typedef reg_c #(s2, "s2") type_id;
  endclass
endpackage
module top;
  sp::sbase s;
  sp::s2 s2;
endmodule
