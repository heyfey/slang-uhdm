// § sysArgUnaryWholeSpan140
module top(input logic signed [7:0] a, output logic o);
  always_comb begin
    if ($signed(-a) > 0) o = 1'b1; else o = 1'b0;
  end
endmodule
