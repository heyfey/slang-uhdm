// § tfArgAliasEndFollows146v
package p;
typedef enum logic [1:0] {A, B, C} e_t;
typedef e_t f_t;
function automatic int f(f_t z);
  return int'(z);
endfunction
function automatic int g(e_t y);
  return int'(y);
endfunction
endpackage
module top(output int o);
  assign o = p::f(p::A) + p::g(p::B);
endmodule
