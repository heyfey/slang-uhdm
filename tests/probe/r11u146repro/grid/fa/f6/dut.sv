// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic e_t f(int g);
  return e_t'(g);
endfunction
endpackage
module top(output logic [1:0] o);
  assign o = p::f(1);
endmodule
