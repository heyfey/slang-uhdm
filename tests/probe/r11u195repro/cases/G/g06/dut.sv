// § evalFuncOpReduceGate195 — grid G/g06 (r11u195, variant c01a)
module top(input logic [7:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return ^d;
  endfunction
  function automatic logic f(input logic [7:0] x);
    logic r;
    r = 1'b0;
    for (int i = 0; i < 4; i++)
      r = g(x[i*2+:2]);
    return r;
  endfunction
  assign o = f(sig);
endmodule
