// § tfArgDefTopSplit176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic int f(e_t g);
    return int'(g);
  endfunction
  function automatic int f2(input e_t g2);
    return int'(g2) * 2;
  endfunction
endpackage
module top (input logic [1:0] s, output int o1, o2, o3);
  function automatic int h(p::e_t k);
    return int'(k) + 1;
  endfunction
  assign o1 = p::f(p::e_t'(s));
  assign o2 = p::f2(p::e_t'(s));
  assign o3 = h(p::e_t'(s));
endmodule
