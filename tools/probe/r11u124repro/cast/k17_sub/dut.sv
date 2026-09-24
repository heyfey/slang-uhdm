// § castTsFile124
module m #(parameter W=3)(input logic [7:0] a, output logic [W-1:0] o); assign o = W'(a); endmodule
module top(input logic [7:0] a, output logic [3:0] o); m #(.W(4)) u(.a(a), .o(o)); endmodule
