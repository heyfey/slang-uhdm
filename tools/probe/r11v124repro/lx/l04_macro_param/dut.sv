// § impLhsCloneFile124
`define DECL(n, v) parameter int n = v;
package p; `DECL(A, 3) endpackage
module top(output int o); import p::*; assign o = A; endmodule
