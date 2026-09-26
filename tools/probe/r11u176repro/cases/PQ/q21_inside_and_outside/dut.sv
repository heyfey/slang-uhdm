// § tfArgDefTopSplit176
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t g);
  return int'(g);
endfunction
endpackage
package q;
function automatic int h(p::e_t k);
  return int'(k);
endfunction
endpackage
