// § evalFuncOpReduceGate195 — grid G/g17 (r11u195, variant c01l)
module top(input logic [7:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return ^d;
  endfunction
  function automatic logic f(input logic [7:0] x);
    logic r, t, q;
    t = x[0];
    r = t + g(x[1:0]);
    return r;
  endfunction
  assign o = f(sig);
endmodule
