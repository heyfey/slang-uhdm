// § tfArgTypedefLastWriter146
package p;
typedef struct packed { logic [1:0] a; } s_t;
function automatic int f(s_t g);
  return int'(g.a);
endfunction
endpackage
module top(output int o);
  assign o = p::f(2'b1);
endmodule
