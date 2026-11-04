// § enumBaseAliasCopyBare446
package p;
  typedef logic [3:0] f_t;
  typedef enum f_t {A = 1, B = 2} e_t;
  function string to_s(e_t r);
    return r.name();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    function string h(e_t r);
      e_t loc;
      loc = r;
      return to_s(loc);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
