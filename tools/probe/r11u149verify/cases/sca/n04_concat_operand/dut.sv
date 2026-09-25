// § sysArgUnaryWholeSpan140
module dut(input logic [3:0] a, input logic [3:0] b, output logic [7:0] y);
  always_comb y = {$unsigned(~a), $unsigned(- b)};
endmodule
