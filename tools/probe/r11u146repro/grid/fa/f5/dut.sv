// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t g);
  return int'(g);
endfunction
function automatic int h(input e_t k);
  return int'(k) + 1;
endfunction
endpackage
module top(output int o);
  assign o = p::f(p::B) + p::h(p::C);
endmodule
