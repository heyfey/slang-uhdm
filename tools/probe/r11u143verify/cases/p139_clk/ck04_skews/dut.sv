// § clockingEventDefNet139
// case ck04: a named clocking block with default skews and an output
module top(input logic clk, input logic a, output logic y);
  clocking cb @(posedge clk);
    default input #1step output #2;
    input a;
    output y;
  endclocking
endmodule
