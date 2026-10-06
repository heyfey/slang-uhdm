// § tpUseSharesOwnTs271
package up;
  class reg_c #(type T = int, T P = 3);
    T m = P;
    function T get(); T l; l = m + P; return l; endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sb;
    typedef reg_c #(shortint, 5) type_id;
  endclass
endpackage
module top;
  sp::sb s;
endmodule
