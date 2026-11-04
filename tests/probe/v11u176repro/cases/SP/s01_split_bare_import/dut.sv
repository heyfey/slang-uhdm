// § tfArgDefTopSplit176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic int f(e_t g);
    return int'(g);
  endfunction
endpackage
module top (input logic [1:0] s, output int o1, o2);
  import p::*;
  function automatic int h(e_t k);
    return int'(k) + 1;
  endfunction
  assign o1 = f(e_t'(s));
  assign o2 = h(e_t'(s));
endmodule
