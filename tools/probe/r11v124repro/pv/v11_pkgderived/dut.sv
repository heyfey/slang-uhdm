// § paramValueIsDefRhs124
package p; parameter int A = 3; parameter int B = A + 2; parameter int C = (72+5-1)/5; localparam logic [7:0] D = 8'hF0 >> 2; endpackage
module top(output int o); assign o = p::B + p::C + p::D; endmodule
