// § paramValueIsDefRhs124
typedef struct packed {logic [3:0] a; logic [3:0] b;} s_t;
module m #(parameter s_t P = '{a:1,b:2})(output logic [7:0] o); assign o = P; endmodule
module top(output logic [7:0] o); m #(.P('{a:3,b:4})) u(.o(o)); endmodule
