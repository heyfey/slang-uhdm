// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, type U = T, type V = U, string Tname = "<unknown>");
    V pv;
    function U f(); V o; o = null; return o; endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(sbase) type_id;
  endclass
endpackage
module top;
  sp::sbase s;
endmodule
