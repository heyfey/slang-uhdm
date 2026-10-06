// § tpUseSharesOwnTs271
package up;
  typedef logic [7:0] byte_t;
  typedef struct packed { logic [3:0] a; } st_t;
  class reg_c #(type T = byte_t, type S = st_t);
    T m;
    S n;
    function T get(); T l; S k; l = m; k = n; return l; endfunction
  endclass
endpackage
package sp;
  import up::*;
  class sb;
    typedef reg_c #(int, st_t) type_id;
  endclass
endpackage
module top;
  sp::sb s;
endmodule
