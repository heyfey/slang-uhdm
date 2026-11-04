// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class b_c #(type T = comp);
    T bm;
  endclass
  class reg_c #(type T = comp, string Tname = "<unknown>") extends b_c #(T);
    T dm;
    function T get(); return dm; endfunction
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
