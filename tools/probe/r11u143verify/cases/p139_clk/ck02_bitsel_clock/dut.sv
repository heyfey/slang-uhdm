// § clockingEventDefNet139
// case ck02: a clocking block whose event is a bit-select of a port vector
module top(input logic [1:0] clks, input logic a, output logic y);
  clocking cb @(posedge clks[0]); input a; endclocking
  always @(posedge clks[0]) y <= a;
endmodule
