// § enumBaseAliasCopyBare446
package p;
  typedef bit [3:0] f_t;
  typedef enum f_t {A = 1, B = 2} e_t;
  class C;
    extern function string h(e_t r);
  endclass
  function string C::h(e_t r);
    return r.name();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    int k;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
