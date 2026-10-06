// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    T m;
    extern function T get();
    extern static function T create(string n = "");
  endclass
  function reg_c::T reg_c::get(); return m; endfunction
  function reg_c::T reg_c::create(string n = ""); T o; return o; endfunction
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
