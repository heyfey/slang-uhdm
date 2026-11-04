// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    typedef reg_c #(T,Tname) this_type;
    local static this_type me = get();
    static function this_type get();
      if (me == null) me = new();
      return me;
    endfunction
    virtual function comp create_component(string name, comp parent);
      T obj;
      obj = new();
      return obj;
    endfunction
    static function T create(string name, comp parent, string contxt="");
      obj o;
      return null;
    endfunction
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
