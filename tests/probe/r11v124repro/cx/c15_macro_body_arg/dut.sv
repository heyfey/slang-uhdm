// § castTsFile124
`define ID(x) x
module top(input logic [7:0] a, output logic [3:0] o); assign o = `ID(4'(a)); endmodule
