// § evalFuncOpReduceGate195 — grid G/g25 (r11u195): a later statement after the stopping one
module top(input logic [7:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return ^d;
  endfunction
  function automatic logic f(input logic [7:0] x);
    logic r;
    r = g(x[1:0]) | g(x[3:2]);
    r = g(x[5:4]);
    return r;
  endfunction
  assign o = f(sig);
endmodule
