// § splitPortIntRedeclLogicTs180 (verifier: a parameterized module, a function writing the integer port)
module dut (a, b);
  parameter int K = 3;
  input  [3:0] a;
  output b;
  integer b;
  function integer f(input [3:0] v); f = v * K; endfunction
  always @(*) b = f(a);
endmodule
