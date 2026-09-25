// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(p::e_t g);
  return int'(g);
endfunction
endpackage
