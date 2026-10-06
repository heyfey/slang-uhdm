// § tpUseSharesOwnTs271
package up;
  class reg_c #(type T = int, type U = T);
    U m;
    function T get(); U l; l = m; return l; endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sb;
    typedef reg_c #(byte) type_id;
  endclass
endpackage
module top;
  sp::sb s;
endmodule
