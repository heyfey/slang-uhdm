// § castTsFile124
`define C(x) 4'(x)
module top(input logic [7:0] a, output logic [3:0] o); assign o = `C(a); endmodule
