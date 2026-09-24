// § castTsFile124
module top(input logic clk, input logic [7:0] a, output integer o); always_ff @(posedge clk) o <= integer'(a); endmodule
