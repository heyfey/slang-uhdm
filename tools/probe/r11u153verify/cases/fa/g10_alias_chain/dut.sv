// § tfArgAliasEndFollows146v
package p;
typedef enum logic [1:0] {A, B, C} e_t;
typedef e_t f_t;
typedef f_t g_t;
function automatic int f(g_t z);
  return int'(z);
endfunction
endpackage
module top(output int o);
  assign o = p::f(p::A);
endmodule
