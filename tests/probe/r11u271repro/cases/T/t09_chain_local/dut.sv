// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, type U = T, string Tname = "<unknown>");
    function void f();
      U o;
      o = null;
    endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(sbase, sbase, "sbase") type_id;
  endclass
endpackage
module top;
  sp::sbase s;
endmodule
