// § evalFuncOpReduceGate195 — grid G/g22 (r11u195): the second call behind a ternary
module top(input logic [7:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return ^d;
  endfunction
  function automatic logic f(input logic [7:0] x);
    logic r;
    r = g(x[1:0]) ? g(x[3:2]) : 1'b0;
    return r;
  endfunction
  assign o = f(sig);
endmodule
