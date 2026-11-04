// § pkgPatReadTsNoParent131
package p; typedef struct packed { logic [1:0] a; logic b; } s_t; parameter s_t P = '{a: 2'b10, b: 1'b1}; endpackage
module sub(output p::s_t o); import p::*; assign o = P; endmodule
module top(output p::s_t o); sub u(.o(o)); endmodule
