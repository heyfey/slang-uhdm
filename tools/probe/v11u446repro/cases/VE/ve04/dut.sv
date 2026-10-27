// § enumBaseAliasCopyBare446
package r;
  typedef bit [3:0] f_t;
endpackage
package p;
  import r::*;
  typedef enum f_t {A = 1, B = 2} e_t;
  function string to_s(e_t r);
    return r.name();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    function string h(e_t a);
      return to_s(a);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
