// § tfArgTypedefLastWriter146
package p;
typedef struct packed { logic [1:0] a; } s_t;
function automatic logic f(s_t g);
  return g.a[0];
endfunction
endpackage
