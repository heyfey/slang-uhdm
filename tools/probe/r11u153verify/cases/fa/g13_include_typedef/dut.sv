// § tfArgTypedefLastWriter146
package p;
`include "td.svh"
function automatic int f(e_t g);
  return int'(g);
endfunction
endpackage
module top(output int o);
  assign o = p::f(p::B);
endmodule
