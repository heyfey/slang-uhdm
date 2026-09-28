// § evalFuncExecCallArgTs191 — fresh: the same function called by a constant and by a non-constant continuous assignment
module top(input logic [3:0] sig, output logic o, output logic p);
  function automatic logic g(input logic [1:0] d);
    return |d;
  endfunction
  function automatic logic f(input logic [3:0] x);
    logic t, u;
    t = g(x[1:0]);
    u = g(x[3:2]);
    return t & u;
  endfunction
  assign o = f(sig);
  assign p = f(4'b1010);
endmodule
