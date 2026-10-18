// § moduleNamedClocking402
module top(input clk, input a, output logic b);
clocking cb @(posedge clk);
  input a;
  output b;
endclocking
endmodule
