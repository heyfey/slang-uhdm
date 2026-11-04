// § evalFuncExecCallArgTs191 — fresh: a local's part select after a plain statement, two calls in one expression, a non-constant call
module top(input logic [5:0] sig, output logic o);
  function automatic logic g(input logic [2:0] d);
    return &d;
  endfunction
  function automatic logic f(input logic [5:0] x);
    logic [5:0] lv;
    lv = x;
    return g(lv[2:0]) | g(lv[5:3]);
  endfunction
  assign o = f(sig);
endmodule
