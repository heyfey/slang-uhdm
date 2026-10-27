// § enumBaseAliasCopyBare446
package p;
  typedef bit [3:0] f_t;
  typedef enum f_t {A = 1, B = 2} e_t;
  function string to_s(e_t r);
    return r.name();
  endfunction
endpackage
package q;
  import p::*;
  function string g(e_t x);
    return to_s(x);
  endfunction
endpackage
module top;
  import q::*;
  initial $display(g(p::A));
endmodule
