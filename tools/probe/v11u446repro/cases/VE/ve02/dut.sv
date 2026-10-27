// § enumBaseAliasCopyBare446
package p;
  typedef bit [3:0] g_t;
  typedef g_t f_t;
  typedef enum f_t {A = 1, B = 2} e_t;
  function string to_s(e_t r);
    return r.name();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    e_t v;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
