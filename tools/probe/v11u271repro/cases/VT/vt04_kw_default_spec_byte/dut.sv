// § tpUseSharesOwnTs271
package up;
  class reg_c #(type T = int);
    T m;
    function T get(); return m; endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sb;
    typedef reg_c #(byte) type_id;
    typedef reg_c #(int) type_id2;
  endclass
endpackage
module top;
  sp::sb s;
endmodule
