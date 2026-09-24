// § pkgPatReadTsNoParent131
package p; typedef struct packed { logic [1:0] a; logic b; } s_t; parameter s_t P = '{2'b10, 1'b1}; endpackage
module top(output p::s_t o); assign o = p::P; endmodule
