// § paramValueIsDefRhs124
module m #(parameter logic [7:0] P = '1, parameter bit [3:0] Q = 'x) (output logic [7:0] o); assign o = P ^ Q; endmodule
module top(output logic [7:0] o); m #(.P(8'h0F)) u(.o(o)); endmodule
