// § enumBaseAliasCopyBare446
package p;
  typedef bit signed [3:0] f_t;
  typedef enum f_t {A = -1, B = 2} e_t;
  function automatic int to_i(e_t r);
    return int'(r);
  endfunction
endpackage
package q;
  import p::*;
  function automatic int g(e_t x);
    e_t y;
    y = x;
    return to_i(y);
  endfunction
endpackage
module top;
  import q::*;
  int o;
  initial o = g(p::A);
endmodule
