// § cloneForIncBindsHomeVar238
// synthesizable: a module calls an importing package's function whose callee loops (downstream lane)
package p;
  function automatic logic [7:0] rev(logic [7:0] x);
    logic [7:0] y;
    for (int i = 0; i < 8; i++) y[i] = x[7-i];
    return y;
  endfunction
  function automatic logic par(logic [7:0] x);
    logic c;
    c = 1'b0;
    for (int i = 0; i < 8; i = i + 1) c = c ^ x[i];
    return c;
  endfunction
endpackage
package q;
  import p::*;
  function automatic logic [7:0] f(logic [7:0] x); return rev(x) ^ {7'b0, par(x)}; endfunction
endpackage
module top(input logic [7:0] a, output logic [7:0] y, output logic c);
  assign y = q::f(a);
  always_comb c = p::par(a);
endmodule
