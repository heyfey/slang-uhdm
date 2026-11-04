// (r11u191 Scr1SvTests N0965) evalFunc's formal typespec on the arguments of the calls a non-constant cont_assign call executes
module top(input logic [3:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return |d;
  endfunction
  function automatic logic f(input logic [3:0] x);
    logic t, u;
    t = g(x[1:0]);
    u = g(x[3:2]);
    return t | u;
  endfunction
  assign o = f(sig);
endmodule
