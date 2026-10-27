// § enumBaseAliasCopyBare446
package p;
  typedef bit [3:0] f_t;
  typedef enum f_t {A = 1, B = 2} e_t;
  function string to_s(e_t r);
    return r.name();
  endfunction
  class C;
    function string h(e_t r);
      return to_s(r);
    endfunction
  endclass
endpackage
module top;
  import p::*;

  C c;
endmodule
