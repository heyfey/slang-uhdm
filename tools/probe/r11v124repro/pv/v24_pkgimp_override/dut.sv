// § paramValueIsDefRhs124
package p; parameter int X = 4; endpackage
module m import p::*; #(parameter int Q = X * 2) (output logic [Q-1:0] o); assign o = '1; endmodule
module top(output logic [11:0] o); m #(.Q(12)) u(.o(o)); endmodule
