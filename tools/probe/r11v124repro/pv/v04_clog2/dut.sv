// § paramValueIsDefRhs124
module m #(parameter int D = 16) (output logic [$clog2(D)-1:0] o); localparam int A = $clog2(D); assign o = A[$clog2(D)-1:0]; endmodule
module top(output logic [4:0] o); m #(.D(32)) u(.o(o)); endmodule
