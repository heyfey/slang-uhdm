// § impLhsCloneFile124
package p; parameter int A = 3; endpackage
package q; parameter int C = 7; endpackage
module top(output int o); import p::*; import q::*; assign o = A + C; endmodule
