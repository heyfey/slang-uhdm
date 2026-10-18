// § undefaultedDefInvalidInst404
module dut #(parameter n) (input [n-1:0] a, output [n-1:0] y);
  for (genvar i = 0; i < n; i++) begin : g
    assign y[i] = ~a[i];
  end
endmodule
module top; endmodule
