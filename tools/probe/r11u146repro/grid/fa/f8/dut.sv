// § tfArgTypedefLastWriter146
package p;
typedef logic [3:0] v_t;
function automatic int f(v_t g);
  return int'(g);
endfunction
endpackage
module top(output int o);
  assign o = p::f(4'd1);
endmodule
