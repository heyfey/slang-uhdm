// § castTsFile124
package p; typedef logic [3:0] n_t; endpackage
module top(input logic [7:0] a, output p::n_t o); assign o = p::n_t'(a); endmodule
