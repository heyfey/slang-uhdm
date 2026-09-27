// § tfArgDefTopSplit176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic int f(e_t g);
    return int'(g);
  endfunction
endpackage
program pr;
  task automatic t(input p::e_t k, output int o);
    o = int'(k);
  endtask
  int r;
  initial begin t(p::B, r); r += p::f(p::C); end
endprogram
