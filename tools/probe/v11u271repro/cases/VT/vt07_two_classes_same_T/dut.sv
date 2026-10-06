// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    T m;
  endclass
  class reg_d #(type T = obj);
    T n;
    static function T make(); T r; return r; endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(sbase, "sbase") type_id;
    typedef reg_d #(sbase) type_id2;
  endclass
endpackage
module top;
  sp::sbase s;
endmodule
