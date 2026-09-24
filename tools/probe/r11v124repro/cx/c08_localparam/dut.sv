// § castTsFile124
module m #(parameter int W = 9) (output logic [3:0] o); localparam logic [3:0] L = 4'(W); assign o = L; endmodule
module top(output logic [3:0] o); m u(.o(o)); endmodule
