// § impLhsCloneFile124
package p; parameter int A = 3; parameter logic [3:0] B = 4'h2; endpackage
module m(output logic [3:0] o); import p::A; import p::B; assign o = A + B; endmodule
module top(output logic [3:0] o); m u(.o(o)); endmodule
