// § enumBaseAliasCopyBare446
package p;
  typedef enum int {A = 1, B = 2} e_t;
  typedef bit [2:0] f_t;
  typedef enum f_t {X = 1, Y = 2} g_t;
  typedef enum f_t {Z = 3, W = 4} h_t;
  function string to_s(e_t r, g_t s, h_t t);
    return r.name();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    function string h(e_t a, g_t b, h_t c);
      return to_s(a, b, c);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
