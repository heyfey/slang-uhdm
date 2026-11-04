// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  interface class ic #(type T = comp);
    pure virtual function T get();
  endclass
  class reg_c #(type T = comp, string Tname = "<unknown>") implements ic #(T);
    T m;
    virtual function T get(); return m; endfunction
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
