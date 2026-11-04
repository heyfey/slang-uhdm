// § evalFuncOpReduceGate195 — grid G/g08 (r11u195, variant c01c)
module top(input logic [7:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return ^d;
  endfunction
  function automatic logic f(input logic [7:0] x);
    logic [3:0] s1;
    for (int unsigned i = 0; i < 4; ++i) begin
      s1[i] = g(x[i*2+:2]);
    end
    return ^s1;
  endfunction
  assign o = f(sig);
endmodule
