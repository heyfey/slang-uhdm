// § evalFuncExecCallArgTs191 — fresh controls: a package function (the law abstains), a call behind an if, a reference actual
package pk;
  function automatic logic g(input logic [1:0] d);
    return |d;
  endfunction
  function automatic logic f(input logic [3:0] x);
    return g(x[1:0]);
  endfunction
endpackage
module top(input logic [3:0] sig, output logic o, output logic p);
  function automatic logic h(input logic [1:0] d);
    return ^d;
  endfunction
  function automatic logic k(input logic [3:0] x);
    logic [1:0] w;
    w = x[1:0];
    if (x[3]) return h(x[3:2]);
    return h(w);
  endfunction
  assign o = pk::f(sig);
  assign p = k(sig);
endmodule
