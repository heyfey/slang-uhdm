// § castTsFile124
`define W 4
module top(input logic [7:0] a, output logic [3:0] o); assign o = `W'(a); endmodule
