// (r11u191 N0965) control: the same function called with a CONSTANT argument (the body folds) and never called
module top(output logic o, output logic p);
  function automatic logic g(input logic [1:0] d);
    return |d;
  endfunction
  function automatic logic f(input logic [3:0] x);
    logic t, u;
    t = g(x[1:0]);
    u = g(x[3:2]);
    return t | u;
  endfunction
  function automatic logic h(input logic [3:0] x);
    return g(x[1:0]);
  endfunction
  assign o = f(4'b0100);
  assign p = 1'b0;
endmodule
