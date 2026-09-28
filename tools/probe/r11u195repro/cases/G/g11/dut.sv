// § evalFuncOpReduceGate195 — grid G/g11 (r11u195, variant c01f)
module top(input logic [7:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return ^d;
  endfunction
  function automatic logic f(input logic [7:0] x);
    logic r;
    r = 1'b0;
    r = r ^ g(x[1:0]);
    return r;
  endfunction
  assign o = f(sig);
endmodule
