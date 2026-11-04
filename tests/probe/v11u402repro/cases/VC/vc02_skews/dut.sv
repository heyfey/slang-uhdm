// § moduleNamedClocking402
module top(input clk, input a, b, output logic c);
  clocking cb @(negedge clk);
    default input #1step output #2;
    input #3 a;
    input b;
    output #1 c;
  endclocking
endmodule
