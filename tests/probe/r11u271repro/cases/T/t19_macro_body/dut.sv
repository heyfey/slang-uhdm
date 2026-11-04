// § tpUseSharesOwnTs271
`define DECL_T T m; \
  function void setm(T v); m = v; endfunction
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    `DECL_T
    function T g();
      T o;
      o = m;
      return o;
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
