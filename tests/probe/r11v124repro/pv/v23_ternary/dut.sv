// § paramValueIsDefRhs124
module m #(parameter int W = 4, parameter int D = (W > 2) ? W : 2) (output logic [D-1:0] o); assign o = '1; endmodule
module top(output logic [7:0] o); m #(.W(8)) u(.o(o)); endmodule
