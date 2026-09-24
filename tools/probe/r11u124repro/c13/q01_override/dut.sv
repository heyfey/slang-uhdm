// § patFlattenTsNoParent124
package p; typedef struct packed { logic [1:0] a; logic b; } s_t; parameter s_t P = '{a: 2'b10, b: 1'b1}; endpackage
module m #(parameter p::s_t Q = '0) (output logic o); assign o = Q.b; endmodule
module top(output logic o); m #(.Q(p::P)) u(.o(o)); endmodule
