// § sysArgUnaryWholeSpan140
module top(input logic [3:0] a, output logic [3:0] o);
  for (genvar g = 0; g < $bits(~a); g++) begin : gl
    assign o[g] = a[g];
  end
endmodule
