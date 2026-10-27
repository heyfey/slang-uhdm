// § enumBaseAliasCopyBare446
package p;
  typedef bit [1:0] f_t;
  typedef enum f_t {A, B, C} e_t;
endpackage
package q;
  import p::*;
  function automatic int g(e_t x);
    return int'(x);
  endfunction
endpackage
module sub(input p::e_t i, output int o);
  import q::*;
  assign o = g(i);
endmodule
module top;
  import p::*;
  e_t s;
  int o;
  sub u(.i(s), .o(o));
endmodule
