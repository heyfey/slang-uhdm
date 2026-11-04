// § castTsFile124
package p; parameter int W = 4; parameter logic [3:0] X = W'(9); endpackage module top(output logic [3:0] o); import p::*; assign o = X; endmodule
