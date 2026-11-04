// § castTsFile124
`define SI(x) shortint'(x)
module top(input logic [7:0] a, output shortint o); always_comb begin o = `SI(a); end endmodule
