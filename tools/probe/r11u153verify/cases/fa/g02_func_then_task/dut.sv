// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t x);
  return int'(x);
endfunction
task automatic t(input e_t y, output int r);
  r = int'(y);
endtask
endpackage
module top(output int o);
  assign o = p::f(p::C);
endmodule
